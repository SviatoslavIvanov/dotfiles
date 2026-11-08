// Local TUI/adapters only: no credentials, network, model calls or agent spawning.
import assert from "node:assert/strict";
import { createRequire } from "node:module";
import { homedir, tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { mkdtempSync, writeFileSync, rmSync } from "node:fs";
import { hostModules } from "./host.mjs";

const root = fileURLToPath(new URL("../", import.meta.url));
const modules = process.env.PI_TEST_NPM_MODULES ?? join(homedir(), ".pi/agent/npm/node_modules");

const host = join(hostModules, "@earendil-works");
const require = createRequire(join(host, "pi-coding-agent/dist/index.js"));
const { createJiti } = await import(pathToFileURL(join(hostModules, "jiti/lib/jiti.mjs")));
const jiti = createJiti(import.meta.url, { moduleCache: true, alias: {
  "typebox/compile": require.resolve("typebox/compile"), "typebox/value": require.resolve("typebox/value"),
  typebox: require.resolve("typebox"),
  "@earendil-works/pi-coding-agent": join(host, "pi-coding-agent/dist/index.js"),
  "@earendil-works/pi-tui": join(host, "pi-tui/dist/index.js"),
  "@earendil-works/pi-ai": join(host, "pi-coding-agent/dist/core/extensions/pi-ai-extension-view.js"),
  "@earendil-works/pi-agent-core": join(host, "pi-agent-core/dist/index.js"),
} });
const api = await jiti.import(join(host, "pi-coding-agent/dist/index.js"));
const tui = await jiti.import(join(host, "pi-tui/dist/index.js"));
api.initTheme("dark", false);
const themeModule = await jiti.import(join(host, "pi-coding-agent/dist/modes/interactive/theme/theme.js"));
const { createEventBus } = await import(pathToFileURL(join(host, "pi-coding-agent/dist/core/event-bus.js")));
const { loadExtensions, createExtensionRuntime } = await import(pathToFileURL(join(host, "pi-coding-agent/dist/core/extensions/loader.js")));
const { collectTasks, runTasks, safeText } = await jiti.import(join(root, "extensions/tasks.ts"));
const polish = await jiti.import(join(root, "extensions/ui-polish.ts"));
const handlers = new Map();
const renderers = new Map();
polish.default({ on: (name, fn) => handlers.set(name, fn), registerMessageRenderer: (type, fn) => renderers.set(type, fn) });
const ui = { get theme() { return themeModule.theme; } };
await handlers.get("session_start")({}, { mode: "tui", ui });
try {
  const models = ["subscription", "api"].map(provider => ({ provider, id: "same-model", name: "Model display name" }));
  const picker = Object.assign(new tui.Container(), {
    filteredModels: models.map(model => ({ model, provider: model.provider, id: model.id })),
    currentModel: models[0], selectedIndex: 0, scopedModels: [], scope: "all",
    searchInput: new tui.Input(), listContainer: new tui.Container(), tui: { terminal: { rows: 24 } },
    modelRuntime: { isUsingSubscription: p => p === "subscription", isUsingOAuth: p => p === "subscription",
      getAvailableSnapshot: () => models, getModel: (provider, id) => models.find(m => m.provider === provider && m.id === id) },
    errorMessage: "Refresh failed; using cache", refreshStatusMessage: "", closed: false,
    refreshAbortController: new AbortController(), onSelectCallback: m => { picker.chosen = m; },
  });
  Object.setPrototypeOf(picker, api.ModelSelectorComponent.prototype);
  for (const appearance of ["dark", "light"]) {
    api.initTheme(appearance, false);
    for (const width of [40, 80, 120]) {
      const lines = picker.render(width);
      assert.ok(lines.length <= 24);
      assert.ok(lines.every(l => tui.visibleWidth(l) <= width));
      const text = lines.map(tui.stripTerminalSequences).join("\n");
      if (width >= 80) { assert.match(text, /subscription/); assert.match(text, /API/); }
      assert.match(text, /Refresh failed/);
    }
  }
  picker.selectedIndex = 1;
  picker.loadModelsFromSnapshot(); picker.filterModels("");
  assert.equal(picker.selectedIndex, 1, "catalog refresh keeps the user's focus instead of jumping to the current model");
  picker.handleInput("\r");
  assert.equal(picker.chosen, models[1], "native model selection still applies the focused model");
  const thinking = new api.ThinkingSelectorComponent("high", ["low", "high"], () => {}, () => {});
  const before = [...thinking.children];
  thinking.render(80);
  assert.deepEqual(thinking.children, before, "compact rendering preserves native input-handler indices");
  thinking.handleInput("l");
  assert.ok(thinking.render(80).length > 0, "filtering still works after a compact render");
  // Shared hint/marker normalization keeps rows in place and speaks one format.
  const t = themeModule.theme, plain = s => tui.stripTerminalSequences(s);
  const cancel = api.keyText("tui.select.cancel"), confirm = api.keyText("tui.select.confirm");
  for (const [input, expected] of [
    ["↑↓ navigate  enter select  escape/ctrl+c cancel", " enter select · escape/ctrl+c cancel"],
    ["(escape/ctrl+c to cancel, enter to submit)", " escape/ctrl+c cancel · enter submit"],
    ["  Enter to select · Ctrl+S to set as default · Escape/Ctrl+C to cancel", ` ${confirm} select · ctrl+s set as default · ${cancel} cancel`],
    ["  Type to search · Enter/Space to change · Esc to cancel", ` type to search · ${confirm}/space change · ${cancel} cancel`],
    ["Enter toggle · Ctrl+A all · Option+Up/Option+Down reorder · 5/25 enabled", ` ${confirm} toggle · ctrl+a all · option+↑↓ reorder · 5/25 enabled`],
  ]) assert.equal(plain(polish.normalizeHint(input, t)), expected);
  assert.equal(polish.normalizeHint("Sign in with Radius • not configured", t), undefined, "content rows are left alone");
  assert.equal(plain(polish.focusMarker(t.fg("accent", "→ ") + "item")), "❯ item");
  assert.equal(plain(polish.focusMarker(" › row")), " ❯ row");
  assert.equal(plain(polish.focusMarker("text → arrow")), "text → arrow", "only a leading marker is replaced");
  const monitor = renderers.get("interactive-shell-monitor-event")({ content: "Monitor Event (ticker) #1\nTrigger: ready", details: { sessionId: "ticker", triggerId: "ready", lineOrDiff: "READY\x1b]52;c;x\x07 7" } }, { expanded: false }, t);
  assert.deepEqual(monitor.render(80).map(plain), ["◆ ticker · ready · READY 7"], "monitor events are one sanitized line");
  const failed = renderers.get("interactive-shell-transfer")({ content: "Session build exited with code 2.\nlog…", details: { exitCode: 2 } }, { expanded: true }, t);
  assert.equal(plain(failed.render(80)[0]), "✗ Session build exited with code 2");
  assert.ok(failed.render(80).length > 1, "Ctrl+O shows the full notification");
} finally { await handlers.get("session_shutdown")(); }
console.log("OK: compact native selectors, themes, narrow widths and native model selection");
console.log("OK: shared hint/marker normalization and compact interactive-shell messages");

const { DialogView } = await jiti.import(join(modules, "@juicesharp/rpiv-ask-user-question/view/dialog-builder.ts"));
const state = { currentTab: 0, notesVisible: false, inputMode: false, answers: new Map(), notesByTab: new Map() };
const pane = { render: () => ["  A", "  B"], setRowAllowance() {}, focusedItemRowRange: () => [0, 1] };
const dialog = new DialogView({
  theme: themeModule.theme, questions: [{ question: "Choose", header: "Scope", options: [] }],
  notesInput: new tui.Input(), isMulti: false, tabsByIndex: [{}],
  getBodyHeight: () => 200, getCurrentBodyHeight: () => 2, getTerminalRows: () => 24,
  collapseKey: "ctrl+]", notesKey: "n",
}, { state, activePreviewPane: pane });
const questionLines = dialog.render(80);
assert.notEqual(tui.stripTerminalSequences(questionLines.at(-1)).trim(), "", "no residual empty tail below question hints");
assert.ok(questionLines.length < 24, "short questions do not fill the terminal budget");
console.log("OK: question dialog has content-sized height and no empty tail");

const bus = createEventBus();
const runtime = createExtensionRuntime();
const loaded = await loadExtensions([join(modules, "pi-bg-tasks/extensions/bg-tasks/index.ts")], root, bus, runtime);
assert.deepEqual(loaded.errors, []);
const { registerUi } = await jiti.import(join(modules, "pi-bg-tasks/extensions/bg-tasks/ui.ts"));
const { BgRegistry } = await jiti.import(join(modules, "pi-bg-tasks/extensions/bg-tasks/registry.ts"));
const reg = new BgRegistry();
const dir = mkdtempSync(join(tmpdir(), "pi-ui-test-"));
try {
  const logPath = join(dir, "output.log");
  writeFileSync(logPath, "job-output\x1b]52;c;attack\x07\n");
  const job = { id: "same-id", command: "check", status: "completed", exitCode: 7, isBackgrounded: true, logPath };
  reg.jobs.set(job.id, job); reg.recentTerminal.push(job);
  registerUi({ events: bus, registerShortcut() {}, registerCommand() {}, registerMessageRenderer() {} }, reg);
  bus.on("sv:tasks:collect", r => r.tasks.push({ id: "same-id", kind: "agent", label: "Agent", active: true, status: "running" }));
  const tasks = collectTasks({ events: bus });
  assert.equal(tasks.filter(t => t.kind === "bash").length, 1, "recent/live registry overlap is deduplicated");
  assert.equal(tasks[0].kind, "agent", "active tasks first; different managers may share an ID");
  assert.match(tasks.find(t => t.kind === "bash").status, /exit 7/);
  assert.match(tasks.find(t => t.kind === "bash").read(), /job-output/);
  assert.doesNotMatch(safeText(tasks.find(t => t.kind === "bash").read()), /\x1b|attack/);

  // Drive the actual picker and output viewer, then back out. Closing never stops a task.
  let stops = 0, opened = 0;
  const local = createEventBus();
  local.on("sv:tasks:collect", r => r.tasks.push({ id: "x", kind: "bash", label: "Build", active: true,
    status: "running", read: () => "hello\nworld", stop: () => { stops++; } }));
  const keys = ["\r", "\x1b", "\x1b"];
  const kb = { matches: (data, key) => ({ "tui.select.confirm": "\r", "tui.select.cancel": "\x1b", "tui.select.up": "\x1b[A", "tui.select.down": "\x1b[B" })[key] === data };
  const ctx = { mode: "tui", ui: {
    select: async () => "View output / events", notify() {}, confirm: async () => true,
    custom: async factory => {
      const key = keys.shift(); assert.ok(key, "unexpected extra dialog");
      let component;
      const result = new Promise(resolve => {
        component = factory({ terminal: { rows: 24 }, requestRender() {} }, themeModule.theme, kb, resolve);
        const lines = component.render(80);
        assert.ok(lines.every(l => tui.visibleWidth(l) <= 80));
        opened++; component.handleInput(key);
      });
      try { return await result; } finally { component.dispose?.(); }
    },
  } };
  await runTasks({ events: local }, ctx);
  assert.equal(opened, 3); assert.equal(stops, 0);
  // Confirmed stop is a separate action; refusal leaves the task running.
  for (const confirmed of [false, true]) {
    keys.push("\r", "\x1b");
    ctx.ui.select = async () => "Stop task…";
    ctx.ui.confirm = async () => confirmed;
    await runTasks({ events: local }, ctx);
  }
  assert.equal(stops, 1);
  console.log("OK: task adapters, namespaced IDs, bounded logs, safe output, back/stop semantics");

  // Real shell adapter, but fake sessions: reading must not call the mutating get()/take().
  const shellBus = createEventBus();
  const shellLoaded = await loadExtensions([join(modules, "pi-interactive-shell/index.ts")], root, shellBus, createExtensionRuntime());
  assert.deepEqual(shellLoaded.errors, []);
  const manager = globalThis.__piInteractiveShellSessionManagerV1;
  const coordinator = globalThis.__piInteractiveShellCoordinatorV1;
  assert.ok(manager); assert.ok(coordinator);
  let killed = 0;
  manager.registerActive({ id: "monitor-test", command: "monitor", getResult: () => undefined,
    getStatus: () => "monitoring", getOutput: () => ({ output: "monitor-output" }), kill: () => { killed++; } });
  coordinator.registerMonitorSession("monitor-test", { strategy: "stream", triggers: [{ id: "ready", literal: "READY" }] }, new Date());
  coordinator.recordMonitorEvent({ sessionId: "monitor-test", strategy: "stream", triggerId: "ready", matchedText: "READY" });
  try {
    const monitor = collectTasks({ events: shellBus }).find(t => t.id === "monitor-test");
    assert.equal(monitor.kind, "monitor"); assert.equal(monitor.active, true);
    assert.equal(monitor.open, undefined, "headless session without a PTY entry must not offer unsupported attach");
    assert.match(monitor.read(), /READY/); assert.match(monitor.read(), /monitor-output/);
    assert.equal(killed, 0); monitor.stop(); assert.equal(killed, 1);
  } finally { manager.unregisterActive("monitor-test"); shellBus.clear(); }
  console.log("OK: live monitor adapter exposes events/output and stops through the existing owner");
} finally { bus.clear(); rmSync(dir, { recursive: true, force: true }); }
