// Native-screen regression checks. Fixtures only: no network, auth, agents or user-file writes.
import assert from "node:assert/strict";
import { createRequire } from "node:module";
import { homedir } from "node:os";
import { join } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { hostModules as modules } from "./host.mjs";
const root = fileURLToPath(new URL("../", import.meta.url));
const host = join(modules, "@earendil-works/pi-coding-agent/dist");
const require = createRequire(join(host, "index.js"));
const { createJiti } = await import(pathToFileURL(join(modules, "jiti/lib/jiti.mjs")));
const jiti = createJiti(import.meta.url, { moduleCache: true, alias: {
  "@earendil-works/pi-coding-agent": join(host, "index.js"),
  "@earendil-works/pi-tui": join(modules, "@earendil-works/pi-tui/dist/index.js"),
  "@earendil-works/pi-ai": join(host, "core/extensions/pi-ai-extension-view.js"),
  "@earendil-works/pi-agent-core": join(modules, "@earendil-works/pi-agent-core/dist/index.js"),
  typebox: require.resolve("typebox"), "typebox/value": require.resolve("typebox/value"), "typebox/compile": require.resolve("typebox/compile"),
} });
const api = await jiti.import(join(host, "index.js"));
const tui = await jiti.import(join(modules, "@earendil-works/pi-tui/dist/index.js"));
const theme = await jiti.import(join(host, "modes/interactive/theme/theme.js"));
const component = async name => jiti.import(join(host, `modes/interactive/components/${name}.js`));
const { KeybindingsManager } = await jiti.import(join(host, "core/keybindings.js"));
const keybindings = new KeybindingsManager();
tui.setKeybindings(keybindings);
const { default: polish } = await jiti.import(join(root, "extensions/ui-polish.ts"));
const handlers = new Map();
polish({ on: (name, fn) => handlers.set(name, fn), registerMessageRenderer() {} });
const originalTreeRender = api.TreeSelectorComponent.prototype.render;
const originalTreeInput = api.TreeSelectorComponent.prototype.handleInput;
const originalAddChild = tui.Container.prototype.addChild;
const originalRenderItem = tui.SelectList.prototype.renderItem;
await handlers.get("session_start")({}, { mode: "tui", ui: { get theme() { return theme.theme; } } });
const noop = () => {};
const text = view => view.render(80).map(tui.stripTerminalSequences).join("\n");
// House style (see extensions/ui-polish.ts): one focus marker, grey rules, keyHint-style hint rows.
const NATIVE_MARKER = /^\s{0,3}[→›▶] /;
const OTHER_HINTS = /^\s*↑↓ (navigate|select) {2}|\bEsc to cancel\b|^\s*Enter to select\b|^\s*\(\S+ to /;
const conforms = (view, lines) => {
  const name = view.constructor.name;
  for (const line of lines) {
    const text = tui.stripTerminalSequences(line);
    assert.doesNotMatch(text, NATIVE_MARKER, `${name}: native focus marker in ${JSON.stringify(text)}`);
    assert.doesNotMatch(text, OTHER_HINTS, `${name}: hint row not in keyHint format: ${JSON.stringify(text)}`);
    if (/^─{8,}$/.test(text)) assert.equal(line, theme.theme.fg("border", text), `${name}: rules use the border colour`);
  }
};
// Non-exported screens are restyled when Pi first shows them (Container.addChild); simulate that.
const shown = view => { new tui.Container().addChild(view); return view; };
const check = view => {
  shown(view);
  const children = view.children && [...view.children];
  for (const width of [40, 80, 120]) {
    const lines = view.render(width);
    assert.ok(lines.length > 0);
    assert.ok(lines.every(line => tui.visibleWidth(line) <= width), `${view.constructor.name} overflows ${width} columns`);
    conforms(view, lines);
  }
  if (children) assert.deepEqual(view.children, children, "render must preserve native handler child indices");
};
const message = (id, role, content, children = []) => ({ entry: {
  id, parentId: null, type: "message", timestamp: "2026-06-01T12:00:00Z",
  message: { role, content: [{ type: "text", text: content }] },
}, children });
try {
  for (const appearance of ["sv-dark", "sv-light"]) {
    api.initTheme(appearance, false);
    let selected, label, copied, cancelled = 0;
    const nodes = [message("root", "user", "Обсудим изменения", [
      message("a", "assistant", "Ответ — " + "длинная строка ".repeat(20)),
      message("b", "user", "ветка с кириллицей"),
    ])];
    const tree = new api.TreeSelectorComponent(nodes, "a", 24, id => selected = id, () => cancelled++, (id, value) => label = [id, value], "b");
    tree.onCopy = value => copied = value;
    check(tree);
    assert.match(text(tree), /Session tree/);
    assert.ok(tree.render(80).some(l => l.includes(theme.theme.fg("accent", theme.theme.bold("Session tree")))), "titles use the accent");
    assert.match(text(tree), /f1.*help/i);
    assert.doesNotMatch(text(tree), /fold|timestamps|labeled only/i, "extended help is initially collapsed");
    const compactRows = tree.render(80).length;
    tree.handleInput("\x1bOP");
    assert.ok(tree.render(80).length > compactRows, "F1 expands the native keybinding-aware help");
    assert.match(text(tree), /branch/i);
    check(tree);
    tree.handleInput("\x1bOP");
    assert.equal(tree.render(80).length, compactRows);
    tree.handleInput("кириллицей");
    assert.equal(tree.getTreeList().getSearchQuery(), "кириллицей");
    tree.handleInput("\x18");
    assert.match(copied, /ветка с кириллицей/);
    tree.handleInput("\r"); assert.equal(selected, "b");
    tree.handleInput("L"); assert.ok(tree.labelInput, "native Shift+L label editing is preserved");
    tree.focused = true; assert.equal(tree.labelInput.focused, true);
    tree.handleInput("метка"); check(tree);
    tree.handleInput("\r"); assert.deepEqual(label, ["b", "метка"]);
    assert.equal(tree.labelInput, null);
    tree.handleInput("\x14"); assert.equal(tree.getTreeList().filterMode, "no-tools");
    tree.handleInput("\x1b"); assert.equal(tree.getTreeList().getSearchQuery(), "");
    tree.handleInput("\x1b"); assert.equal(cancelled, 1);
    const many = Array.from({ length: 60 }, (_, i) => message(`n${i}`, "user", `message ${i}`));
    const tall = new api.TreeSelectorComponent(many, "n40", 24, noop, noop);
    for (const width of [40, 80, 120]) {
      assert.ok(tall.render(width).length <= 24);
      tall.handleInput("\x1bOP");
      assert.ok(tall.render(width).length <= 24, "expanded help leaves room for the tree on 80×24 and narrower terminals");
      tall.handleInput("\x1bOP");
    }
    tall.handleInput("\x1b[1;3D"); check(tall); // Native fold/unfold encodings.
    tall.handleInput("\x1b[1;3C"); check(tall);

    const fork = new api.UserMessageSelectorComponent([{ id: "b", text: "Продолжить ветку", timestamp: "2026-06-01" }], id => selected = id, noop);
    check(fork); fork.getMessageList().handleInput("\r"); assert.equal(selected, "b");
    const sessions = [{ path: "/fixture/session.jsonl", id: "s", cwd: "/fixture", name: "Example session", firstMessage: "первое сообщение", messageCount: 4, created: new Date(), modified: new Date() }];
    const resume = new api.SessionSelectorComponent(async () => sessions, async () => sessions, path => selected = path, noop, noop, noop, { keybindings, renameSession: async () => {} });
    await Promise.resolve(); await Promise.resolve();
    check(resume);
    const resumeRows = resume.render(80).map(tui.stripTerminalSequences);
    assert.match(resumeRows[1], /^ Resume session · current folder .*all names · sort threaded$/, "one title row, filters on the right");
    assert.match(resumeRows.at(-2), /^ enter resume · .*escape\/ctrl\+c back$/, "key hints are one row at the bottom");
    assert.equal(resumeRows.filter(l => / scope · /.test(l)).length, 1, "no second hint block above the list");
    resume.handleInput("Example"); check(resume);
    resume.handleInput("\r"); assert.equal(selected, sessions[0].path);
    resume.handleInput("\x12"); check(resume); // Rename UI only; never submit to disk.
    resume.handleInput("\x1b"); check(resume); resume.handleInput("\x1b");

    const { McpManagerView } = await jiti.import(join(host, "extensions/mcp/ui.js"));
    const mcp = new McpManagerView({ requestRender: noop, terminal: { rows: 24, columns: 80 } }, theme.theme, keybindings);
    check(mcp);
    let refresh;
    const menuResult = mcp.menu(() => ({ title: "MCP servers", items: [{ value: "one", label: "Connected" }, { value: "two", label: "Needs login" }], confirmLabel: "open", cancelLabel: "back" }), listener => { refresh = listener; return noop; });
    mcp.handleInput("\x1b[B"); refresh(); check(mcp); mcp.handleInput("\r");
    assert.equal(await menuResult, "two", "MCP status refresh preserves the selected server");
    let authCancelled = false;
    mcp.status("Signing in", "Approve in browser", () => authCancelled = true); check(mcp);
    mcp.handleInput("\x1b"); assert.equal(authCancelled, true);
    const controller = new AbortController();
    const redirect = mcp.redirectUrl("Sign in", "https://example.invalid/authorize", controller.signal);
    mcp.focused = true; check(mcp); controller.abort(); assert.equal(await redirect, undefined);
    const { ScopedModelsSelectorComponent } = await component("scoped-models-selector");
    let persisted = 0, changed = 0;
    const scope = new ScopedModelsSelectorComponent({ allModels: [{ provider: "fixture", id: "model", name: "Example" }], enabledModelIds: null }, {
      onChange: () => changed++, onPersist: () => persisted++, onCancel: noop,
    });
    check(scope); scope.handleInput("\r"); assert.equal(changed, 1); assert.equal(persisted, 0);
    scope.handleInput("\x13"); assert.equal(persisted, 1); check(scope);
    const { TrustSelectorComponent } = await component("trust-selector");
    check(new TrustSelectorComponent({ cwd: "/fixture", savedDecision: null, projectTrusted: false, onSelect: noop, onCancel: noop }));
    const { FirstTimeSetupComponent } = await component("first-time-setup");
    const setup = new FirstTimeSetupComponent({ onThemePreview: noop, onSubmit: noop, onCancel: noop });
    check(setup); setup.handleInput("\r"); check(setup);
    const { SelectSubmenu, SteppedSubmenu } = await component("settings-submenu");
    const options = [{ value: "a", label: "Alpha", description: "A setting" }, { value: "b", label: "Beta" }];
    check(new SelectSubmenu("Theme", "Choose", options, "a", noop, noop, noop, { searchable: true }));
    const steps = new SteppedSubmenu(["provider", "model"].map(key => ({ key, title: key, description: "Choose", options: () => options })), noop, noop);
    check(steps); steps.handleInput("\r"); check(steps); steps.handleInput("\x1b"); check(steps);
    check(new api.ExtensionSelectorComponent("Confirm", ["Yes", "No"], noop, noop));
    check(new api.ExtensionInputComponent("Name", "Type…", noop, noop));
    check(new api.ExtensionEditorComponent({ requestRender: noop, terminal: { rows: 24 } }, keybindings, "Notes", "Текст", noop, noop));
    const { ConfigSelectorComponent } = await component("config-selector");
    const emptyPaths = { extensions: [], skills: [], prompts: [], themes: [] };
    check(new ConfigSelectorComponent({ global: emptyPaths, project: emptyPaths }, api.SettingsManager.inMemory(), "/fixture", "/fixture/.pi", noop, noop, noop, 24));
    const settings = new api.SettingsSelectorComponent({
      autoCompact: true, defaultModel: "fixture/model", availableDefaultModels: [], showImages: true,
      imageWidthCells: 80, autoResizeImages: true, blockImages: false, enableSkillCommands: false,
      steeringMode: "one-at-a-time", followUpMode: "one-at-a-time", transport: "sse",
      sessionShareDestination: "clipboard", httpIdleTimeoutMs: 300000, cacheWarmingMode: "off",
      thinkingLevel: "high", availableThinkingLevels: ["low", "high"], modelThinkingLevels: {},
      currentTheme: appearance, terminalTheme: {}, availableThemes: ["sv-dark", "sv-light"], hideThinkingBlock: true,
      mermaidRenderingMode: "off", showCacheMissNotices: false, collapseChangelog: true, enableInstallTelemetry: false,
      doubleEscapeAction: "tree", treeFilterMode: "default", showHardwareCursor: true, editorPaddingX: 1, outputPad: 0,
      autocompleteMaxVisible: 5, quietStartup: true, defaultProjectTrust: "ask", clearOnShrink: true,
      showTerminalProgress: true, tuiMode: "fullscreen", fullscreenExitOutput: "none", fullscreenScrollbar: "auto",
      fullscreenCopyOnSelect: false, fullscreenWheelScrollLines: 3, warnings: {},
    }, new Proxy({}, { get: () => noop }));
    check(settings); settings.getSettingsList().handleInput("\x1b[B"); check(settings);
    check(new api.ShowImagesSelectorComponent(true, noop, noop));
    check(new api.ThinkingSelectorComponent("high", ["low", "high"], noop, noop));
    check(new api.ThemeSelectorComponent(appearance, noop, noop, noop));
    for (const mode of ["login", "logout"]) check(new api.OAuthSelectorComponent(mode, [{ id: "fixture", name: "Example", authType: "oauth" }], noop, noop));
    const login = new api.LoginDialogComponent({ requestRender: noop }, "fixture", noop);
    login.showAuth("https://example.invalid/authorize", "Instructions"); check(login);
    login.showWaiting("Waiting for approval"); check(login);
    const prompt = login.showPrompt("Code"); login.handleInput("fixture"); login.handleInput("\r");
    assert.equal(await prompt, "fixture"); check(login);
    const npmModules = process.env.PI_TEST_NPM_MODULES ?? join(homedir(), ".pi/agent/npm/node_modules");
    const { SettingsListWrapper } = await jiti.import(join(npmModules, "pi-subagents-lite/src/ui/menu/wrappers/settings-list.ts"));
    const list = new tui.SelectList(options, 10, { selectedPrefix: s => s, selectedText: s => s, description: s => s, scrollInfo: s => s, noMatch: s => s });
    let menuClosed = false;
    const wrapper = new SettingsListWrapper(list, { title: "Agents", theme: theme.theme, onCancel: () => menuClosed = true });
    check(wrapper);
    assert.equal(wrapper.render(80).length, list.render(80).length + 4, "agent menus add only title, two borders and visible navigation hints");
    assert.match(text(wrapper), /enter.*select.*back/i);
    wrapper.handleInput("j"); assert.equal(list.getSelectedItem().value, "b");
    wrapper.handleInput("\x1b"); assert.equal(menuClosed, true);
    const input = new tui.Input();
    const inputWrapper = new SettingsListWrapper(input, { title: "Agent prompt", theme: theme.theme, passthroughKeys: true });
    inputWrapper.handleInput("j"); inputWrapper.handleInput("k");
    assert.equal(input.getValue(), "jk", "letters remain text in the agent prompt"); check(inputWrapper);
    console.log(`OK: ${appearance} agent menu frame and prompt input`);
    console.log(`OK: ${appearance} native tree, resume, fork, model scope, MCP, trust, setup, config/settings, submenus, select/input/editor, effort, theme and auth layouts`);
    console.log(`OK: ${appearance} house style: ❯ focus marker, grey rules, keyHint rows on every screen above`);
  }
} finally { await handlers.get("session_shutdown")(); }
assert.equal(api.TreeSelectorComponent.prototype.render, originalTreeRender);
assert.equal(api.TreeSelectorComponent.prototype.handleInput, originalTreeInput);
assert.equal(tui.Container.prototype.addChild, originalAddChild);
assert.equal(tui.SelectList.prototype.renderItem, originalRenderItem);
console.log("OK: shutdown restores native rendering and input handlers");
