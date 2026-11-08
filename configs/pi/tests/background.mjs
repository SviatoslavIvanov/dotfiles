// Real shell processes through Pi's loader. No model calls or credentials.
import assert from "node:assert/strict";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir, homedir } from "node:os";
import { join } from "node:path";
import { pathToFileURL } from "node:url";
import { hostModules as host } from "./host.mjs";

const modules = process.env.PI_TEST_NPM_MODULES ?? join(homedir(), ".pi/agent/npm/node_modules");
const { loadExtensions, createExtensionRuntime } = await import(pathToFileURL(join(host, "@earendil-works/pi-coding-agent/dist/core/extensions/loader.js")));
const cwd = mkdtempSync(join(tmpdir(), "pi-background-test-"));
const runtime = createExtensionRuntime();
const messages = [], waiters = new Map(), logs = new Set();
runtime.sendMessage = (message, options) => {
  messages.push({ message, options });
  waiters.get(message.details?.jobId)?.(message);
};
const loaded = await loadExtensions([join(modules, "pi-bg-tasks/extensions/bg-tasks/index.ts")], cwd, undefined, runtime);
assert.deepEqual(loaded.errors, []);
const extension = loaded.extensions[0];
const ctx = { cwd, hasUI: true, mode: "tui", ui: {
  theme: { fg: (_color, text) => text }, notify() {}, setStatus() {}, setWidget() {},
} };
const emit = async (name, event = {}) => {
  for (const handler of extension.handlers.get(name) ?? []) await handler(event, ctx);
};
const bounded = async (promise) => {
  let timer;
  try {
    return await Promise.race([promise, new Promise((_, reject) => {
      timer = setTimeout(() => reject(new Error("background test deadline")), 10000);
    })]);
  } finally { clearTimeout(timer); }
};
const call = async (name, params) => {
  const result = await bounded(extension.tools.get(name).definition.execute("test", params, undefined, undefined, ctx));
  const text = result.content.map((part) => part.text ?? "").join("\n");
  for (const match of text.matchAll(/\/tmp\/pi-bg-tasks\/bash-[a-z0-9]+\.log/g)) logs.add(match[0]);
  return text;
};
const start = async (command) => {
  const text = await call("bash", { command, run_in_background: true });
  const id = /with ID: (bash-[a-z0-9]+)\b/.exec(text)?.[1];
  assert.ok(id, text);
  return id;
};
const completion = async (id) => {
  try {
    return messages.find(({ message }) => message.details?.jobId === id)?.message ??
      await bounded(new Promise((resolve) => waiters.set(id, resolve)));
  } finally { waiters.delete(id); }
};
try {
  await emit("session_start");
  for (const [command, status, output] of [
    ["sleep 0.1; echo background-ok", "completed", "background-ok"],
    ["sleep 0.1; echo background-error >&2; exit 9", "failed", "background-error"],
  ]) {
    const id = await start(command);
    assert.equal((await completion(id)).details.status, status);
    assert.ok((await call("bg_output", { task_id: id })).includes(output));
    const notices = messages.filter(({ message }) => message.details?.jobId === id);
    assert.equal(notices.length, 1, "one completion notification per job");
    assert.equal(notices[0].options.triggerTurn, true, "completion must wake the agent");
  }
  const stopped = await start("sleep 30");
  assert.match(await call("bg_stop", { task_id: stopped }), /stopped/);
  assert.match(await call("bg_output", { task_id: stopped }), /Status: killed/);
  const reloaded = await start("sleep 30");
  await bounded(emit("session_shutdown", { reason: "reload" }));
  assert.match(await call("bg_output", { task_id: reloaded }), /Status: killed/);
  assert.ok(!messages.some(({ message }) => [stopped, reloaded].includes(message.details?.jobId)), "intentional cleanup must not wake the agent");
  console.log("OK: background success/error, output, wake-up, stop and reload cleanup");
} finally {
  await bounded(emit("session_shutdown", { reason: "quit" }));
  for (const log of logs) rmSync(log, { force: true });
  rmSync(cwd, { recursive: true, force: true });
}
