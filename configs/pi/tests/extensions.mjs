// Compatibility + local billing/model regressions. No model calls or credentials.
import assert from "node:assert/strict";
import { existsSync, readFileSync, readdirSync, statSync } from "node:fs";
import { join } from "node:path";
import { createRequire } from "node:module";
import { homedir } from "node:os";
import { fileURLToPath, pathToFileURL } from "node:url";

const root = fileURLToPath(new URL("../", import.meta.url));
const modules = process.env.PI_TEST_NPM_MODULES ?? join(homedir(), ".pi/agent/npm/node_modules");
const hostModules = process.env.PI_TEST_HOST_MODULES ?? join(homedir(), ".pi/agent/install/releases/1.5.0/node_modules");
const host = join(hostModules, "@earendil-works");
const { loadExtensions, createExtensionRuntime } = await import(pathToFileURL(join(host, "pi-coding-agent/dist/core/extensions/loader.js")));
const settings = JSON.parse(readFileSync(join(root, "settings.json"), "utf8"));
const paths = [];
function addExtension(path) {
  if (!statSync(path).isDirectory()) {
    if (/\.(ts|js)$/.test(path) && !path.endsWith(".d.ts")) paths.push(path);
  } else if (existsSync(join(path, "index.ts")) || existsSync(join(path, "index.js"))) {
    paths.push(path);
  } else {
    for (const child of readdirSync(path)) addExtension(join(path, child));
  }
}
for (const entry of settings.packages) {
  const source = typeof entry === "string" ? entry : entry.source;
  const dir = join(modules, source.slice(4).replace(/@[^@/]+$/, ""));
  const manifest = JSON.parse(readFileSync(join(dir, "package.json"), "utf8"));
  for (const path of manifest.pi.extensions) addExtension(join(dir, path));
}
for (const name of readdirSync(join(root, "extensions"))) {
  if (name.endsWith(".ts")) paths.push(join(root, "extensions", name));
}
const runtime = createExtensionRuntime();
runtime.getSettings = () => settings;
const loaded = await loadExtensions(paths, root, undefined, runtime);
assert.deepEqual(loaded.errors, []);
for (const field of ["shortcuts", "commands"]) {
  const names = loaded.extensions.flatMap((extension) => [...extension[field].keys()]);
  assert.equal(new Set(names).size, names.length, `duplicate extension ${field}`);
}
assert.equal(loaded.extensions.filter((extension) => extension.tools.has("bash")).length, 1, "bash must have one owner");
console.log(`OK: ${loaded.extensions.length} extensions load without command/shortcut conflicts`);

// Pi supplies peer modules; use its mapping when importing patched TypeScript.
const { createJiti } = await import(pathToFileURL(join(hostModules, "jiti/lib/jiti.mjs")));
const hostRequire = createRequire(join(host, "pi-coding-agent/dist/index.js"));
const jiti = createJiti(import.meta.url, { moduleCache: true, alias: {
  "typebox/compile": hostRequire.resolve("typebox/compile"),
  "typebox/value": hostRequire.resolve("typebox/value"),
  "typebox": hostRequire.resolve("typebox"),
  "@earendil-works/pi-coding-agent": join(host, "pi-coding-agent/dist/index.js"),
  "@earendil-works/pi-tui": join(host, "pi-tui/dist/index.js"),
  "@earendil-works/pi-ai": join(host, "pi-coding-agent/dist/core/extensions/pi-ai-extension-view.js"),
  "@earendil-works/pi-agent-core": join(host, "pi-agent-core/dist/index.js"),
}});
const { sessionCost } = await jiti.import(join(modules, "pi-minimal-footer/extensions/lib/session-cost.ts"));
const { trackSubagentCosts, CHILD_COST_CHANNEL } = await jiti.import(join(modules, "pi-minimal-footer/extensions/lib/subagent-costs.ts"));
const cost = { input: 1, output: 1, cacheRead: 0, cacheWrite: 0 };
const subscription = { provider: "openai", id: "subscription-model", cost };
const api = { provider: "anthropic", id: "api-model", cost };
const registry = {
  isUsingOAuth: (model) => model.provider === subscription.provider,
  getProvider: () => ({ auth: { oauth: { isSubscription: true } } }),
  find: (provider, id) => [subscription, api].find((model) => model.provider === provider && model.id === id),
};
const usage = (model, total) => ({ type: "message", message: { role: "assistant", provider: model.provider, model: model.id, usage: { cost: { total } } } });
const context = (model, entries) => ({ model, modelRegistry: registry, sessionManager: { getEntries: () => entries, getSessionId: () => "parent" } });
const history = [usage(subscription, 12), usage(api, 0.3)];
assert.equal(sessionCost(context(subscription, history)), "API ~$0.30", "switching to subscription must preserve API spend");
assert.equal(sessionCost(context(api, history)), "~$0.30", "switching to API must not price subscription history");
assert.equal(sessionCost(context(api, [usage(api, 0.004)])), "<$0.01", "tiny API spend stays visible without noise");

// A child reports cumulative usage: duplicate events must not count it twice.
const events = new Map(), entries = [];
const ctx = context(subscription, entries);
let childCost = 0, onChildEvent;
const child = { sessionId: "child", model: api, getSessionStats: () => ({ cost: childCost }), subscribe: (listener) => { onChildEvent = listener; return () => {}; } };
const stop = trackSubagentCosts({ events: { on: (name, listener) => events.set(name, listener) }, appendEntry: (customType, data) => entries.push({ type: "custom", customType, data }) }, () => ctx, () => {});
try {
  events.get(CHILD_COST_CHANNEL)({ parentSessionId: "parent", session: child });
  for (const amount of [0.2, 0.3]) {
    childCost = amount;
    onChildEvent({ type: "message_end" });
    onChildEvent({ type: "agent_end" });
    await new Promise(queueMicrotask);
  }
  assert.equal(sessionCost(ctx), "API ~$0.30");
  child.model = subscription;
  childCost = 9.3;
  onChildEvent({ type: "agent_end" });
  await new Promise(queueMicrotask);
  assert.equal(sessionCost(ctx), "API ~$0.30", "child subscription usage must not increase API spend");
} finally { stop(); }
assert.equal(sessionCost(context(subscription, structuredClone(entries))), "API ~$0.30", "persisted child costs survive restore");
console.log("OK: parent model switching and cumulative child API costs");

const { findModelInRegistry } = await jiti.import(join(modules, "pi-subagents-lite/src/utils.ts"));
assert.equal(findModelInRegistry(undefined, registry, subscription), subscription, "omitted model inherits parent");
assert.equal(findModelInRegistry("anthropic/api-model", registry, subscription), api, "explicit available model wins");
const { executeAgentTool } = await jiti.import(join(modules, "pi-subagents-lite/src/agents/tool-execution.ts"));
await assert.rejects(executeAgentTool("missing-model", {
  agent: "general-purpose", model: "anthropic/missing", prompt: "Must fail before spawning.",
}, undefined, undefined, { ...ctx, cwd: root, isProjectTrusted: () => false }), /Subagent model not found/);
console.log("OK: Agent rejects a missing explicit model instead of spawning its parent model");
