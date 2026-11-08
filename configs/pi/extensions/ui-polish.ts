import { ModelSelectorComponent, TreeSelectorComponent, SessionSelectorComponent, UserMessageSelectorComponent, ExtensionSelectorComponent, ExtensionInputComponent, ThinkingSelectorComponent, ThemeSelectorComponent, SettingsSelectorComponent, OAuthSelectorComponent, LoginDialogComponent, ShowImagesSelectorComponent, ExtensionEditorComponent, DynamicBorder, keyHint, keyText, rawKeyHint, type ExtensionAPI, type Theme } from "@earendil-works/pi-coding-agent";
import { Container, SelectList, SettingsList, Spacer, Text, matchesKey, stripTerminalSequences, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

// One house style for short menus and dialogs (Pi 1.5.0 native, made consistent):
//   ───────────────  grey border (accent borders belong to the editor's thinking level)
//    Title · context accent bold title, muted context, sentence case, no trailing colon
//   ❯ focused row    accent focus marker; ✓ marks the current value
//    enter select · escape/ctrl+c back   keyHint parts: dim key, muted action, dim " · "
//   ───────────────
// Everything here is presentation only: native handlers, row counts and child indices stay intact.
export const FOCUS = "❯";
const ANSI = /\x1b\[[0-9;:]*m/g;
const plain = (line: string) => line.replace(ANSI, "");
const NATIVE_FOCUS = /^((?:\x1b\[[0-9;:]*m)*[ ]{0,3}(?:\x1b\[[0-9;:]*m)*)(?:→|›|▶) /;

/** Replace Pi's mixed list markers (→ › ▶) at the start of a row with the shared focus marker. */
export const focusMarker = (line: string) => line.replace(NATIVE_FOCUS, `$1${FOCUS} `);

export function titleLine(theme: Theme, title: string, context?: string): string {
  return ` ${theme.fg("accent", theme.bold(title))}${context ? theme.fg("muted", ` · ${context}`) : ""}`;
}

export function hintLine(theme: Theme, parts: string[], indent = 1): string {
  return " ".repeat(indent) + parts.filter(Boolean).join(theme.fg("dim", " · "));
}

export const borderLine = (theme: Theme, width: number) => theme.fg("border", "─".repeat(Math.max(1, width)));

const keyPart = (theme: Theme, key: string, action: string) => theme.fg("dim", key) + theme.fg("muted", ` ${action}`);
/** Human key labels ("Esc", "Enter/Space") → Pi's lowercase names of the keys actually bound. */
const nativeKey = (key: string) => {
  const parts = key.toLowerCase().split("/");
  if (parts.some(k => k === "esc" || k === "escape")) return keyText("tui.select.cancel");
  if (parts[0] === "enter") parts[0] = keyText("tui.select.confirm");
  return parts.join("/").replace(/^(\w+)\+up\/\1\+down$/, "$1+↑↓");
};

// Core titles in Title Case; everything else in Pi is sentence case.
const SENTENCE_CASE: Record<string, string> = {
  "Resume Session": "Resume session", "Model Configuration": "Model configuration",
  "Automatic Theme": "Automatic theme", "Fork from Message": "Fork from message", "Thinking Level": "Thinking level",
};
const sentenceCase = (line: string, theme: Theme) => {
  // Session titles are drawn in plain bold; give them the accent like every other title.
  for (const title of ["Resume Session", "Rename Session"]) {
    if (line.includes(title)) return line.replace(title, theme.fg("accent", title.replace(" Session", " session")));
  }
  for (const [from, to] of Object.entries(SENTENCE_CASE)) if (line.includes(from)) return line.replace(from, to);
  return line;
};

/** "Key to action" (Pi's sentence-style hints) → keyHint part; "Type to search" stays plain. */
const sentencePart = (theme: Theme, part: string) => {
  const m = /^(\S+) to (.+)$/.exec(part.trim());
  if (!m || /^type$/i.test(m[1])) return theme.fg("muted", part.trim().toLowerCase());
  return keyPart(theme, nativeKey(m[1]), m[2]);
};

// A key label as Pi prints it: optional modifiers, then a named key or arrows.
const KEY = /^(?:(?:ctrl|shift|alt|option|cmd)\+)*(?:enter|esc|escape|tab|space|up|down|left|right|pgup|pgdn|home|end|f\d+|↑↓|↑|↓|[a-z\]\[])(?:\/(?:(?:ctrl|shift|alt|option|cmd)\+)*(?:enter|esc|escape|tab|space|up|down|left|right|[a-z]))*$/i;
const NAMED_KEY = /enter|esc|tab|space|ctrl|shift|alt|option|↑|↓|f\d/i;

/**
 * Rewrite core hint rows that use other formats into keyHint style, keeping the row in place:
 * "↑↓ navigate  enter select  escape/ctrl+c cancel", "(escape/ctrl+c to cancel)",
 * "Enter to select · Ctrl+S to set as default · Escape/Ctrl+C to cancel",
 * "Enter toggle · Ctrl+A all · 5/25 enabled". Returns undefined otherwise.
 */
export function normalizeHint(line: string, theme: Theme): string | undefined {
  const trimmed = plain(line).trim();
  if (!trimmed) return undefined;
  if (/^↑↓ (navigate|select) {2}/.test(trimmed)) {
    const parts = trimmed.split(/ {2,}/).slice(1).map(part => {
      const [key, ...action] = part.split(" ");
      return keyPart(theme, key, action.join(" "));
    });
    return hintLine(theme, parts);
  }
  const paren = /^\((\S+ to .+)\)$/.exec(trimmed);
  if (paren) return hintLine(theme, paren[1].split(/,\s*/).map(part => sentencePart(theme, part)));
  const parts = trimmed.split(" · ");
  const sentence = parts.length >= 2 && parts.every(part => {
    const m = /^(\S+) to \S/.exec(part);
    return m && (/^type$/i.test(m[1]) || (KEY.test(m[1]) && NAMED_KEY.test(m[1])));
  });
  if (sentence) return hintLine(theme, parts.map(part => sentencePart(theme, part)));
  const keyed = parts.map(part => /^(\S+) (.+)$/.exec(part)).map(m => m && KEY.test(m[1]) && NAMED_KEY.test(m[1]) ? m : null);
  if (parts.length >= 2 && keyed[0] && keyed.filter(Boolean).length >= 2 && /[A-Z]/.test(trimmed[0])) {
    return hintLine(theme, parts.map((part, i) => keyed[i] ? keyPart(theme, nativeKey(keyed[i]![1]), keyed[i]![2]) : theme.fg("muted", part)));
  }
  return undefined;
}

/**
 * Line-count preserving normalization for rendered menu chrome: grey rules, keyHint rows,
 * the shared focus marker and a title without a trailing colon.
 */
export function normalizeChrome(lines: string[], theme: Theme): string[] {
  let titleSeen = false;
  return lines.map(line => {
    const text = plain(line);
    if (/^─{8,}$/.test(text)) return theme.fg("border", text);
    const hint = normalizeHint(line, theme);
    if (hint) return hint;
    if (!titleSeen && text.trim()) {
      titleSeen = true;
      if (/^\s*[A-Z].*:\s*$/.test(text)) return line.replace(/:((?:\x1b\[[0-9;:]*m|\s)*)$/, "$1");
      return focusMarker(sentenceCase(line, theme));
    }
    return focusMarker(line);
  });
}

/** Rewrite hint Text children before layout, so long hints wrap as keyHint rows instead of being split. */
function normalizeTextChildren(component: any, theme: Theme, done = new WeakMap<object, string>()) {
  for (const child of component?.children ?? []) {
    if (child instanceof Container) { normalizeTextChildren(child, theme, done); continue; }
    if (typeof child?.text !== "string" || typeof child.setText !== "function" || done.get(child) === child.text) continue;
    const next = normalizeHint(child.text, theme);
    // The Text keeps its own padding; carry over only the original leading spaces.
    if (next) child.setText(/^\s*/.exec(plain(child.text))![0] + next.trimStart());
    done.set(child, child.text);
  }
}

// Pi 1.5.0: presentation only. Keep the native search, refresh, auth, scope and save handlers.
export function modelPickerLines(picker: any, width: number, theme: Theme): string[] {
  const models = picker.filteredModels;
  const limit = Math.max(1, Math.min(7, picker.tui.terminal.rows - 10));
  const start = Math.max(0, Math.min(picker.selectedIndex - Math.floor(limit / 2), models.length - limit));
  const same = (a: any, b: any) => a?.id === b?.id && a?.provider === b?.provider;
  const lines: string[] = [];
  for (let i = start; i < Math.min(start + limit, models.length); i++) {
    const { model } = models[i];
    const current = same(model, picker.currentModel);
    const focused = i === picker.selectedIndex;
    const billing = picker.modelRuntime.isUsingSubscription(model.provider) ? "subscription"
      : picker.modelRuntime.isUsingOAuth(model.provider) ? "OAuth" : "API";
    const effort = picker.scopedModels.find((s: any) => same(s.model, model))?.thinkingLevel;
    const prefix = theme.fg("accent", `${focused ? FOCUS : " "} ${current ? "✓" : " "}`);
    const name = theme.fg(focused ? "accent" : "text", model.name || model.id);
    const meta = theme.fg("muted", ` · ${model.provider} · ${billing}${effort ? ` · ${effort}` : ""}${picker.isDefaultModel(model) ? " · default" : ""}`);
    // The provider/billing suffix must survive even when the display name is very long.
    const nameWidth = Math.max(8, width - 5 - (model.provider.length + billing.length + (effort?.length ?? 0) + 14));
    lines.push(truncateToWidth(`${prefix} ${truncateToWidth(name, nameWidth)}${meta}`, width));
  }
  if (!models.length) lines.push(theme.fg("muted", " No matching models"));
  const selected = models[picker.selectedIndex];
  if (selected) lines.push(theme.fg("dim", ` ${selected.provider}/${selected.id} · ${picker.selectedIndex + 1}/${models.length}`));
  if (picker.errorMessage) lines.push(theme.fg("error", ` ${picker.errorMessage}`));
  else if (picker.refreshStatusMessage && !picker.refreshStatusSuccess) lines.push(theme.fg("dim", " Refreshing catalog…"));
  return lines.map(l => truncateToWidth(l, width));
}

// /resume (Pi 1.5.0 SessionSelectorHeader): one title row with the scope as context and the
// filters on the right; the key hints move to one row at the bottom, like every other menu.
const sessionLayout = (header: any) => typeof header?.scope === "string" && "sortMode" in header &&
  "nameFilter" in header && "confirmingDeletePath" in header && "statusMessage" in header;

export function sessionTitleRow(header: any, width: number, theme: Theme): string {
  const context = header.loading
    ? `loading ${header.loadProgress ? `${header.loadProgress.loaded}/${header.loadProgress.total}` : "…"}`
    : header.scope === "current" ? "current folder" : "all folders";
  const left = titleLine(theme, "Resume session", context);
  const right = theme.fg("muted", `${header.nameFilter === "named" ? "named only" : "all names"} · sort ${header.sortMode}`);
  if (visibleWidth(left) + visibleWidth(right) + 2 > width) return truncateToWidth(left, width, "…");
  return left + " ".repeat(width - visibleWidth(left) - visibleWidth(right)) + right;
}

export function sessionHintRow(header: any, width: number, theme: Theme): string {
  if (header.confirmingDeletePath !== null) {
    return truncateToWidth(` ${theme.fg("error", "Delete session?")} ${hintLine(theme, [
      keyHint("tui.select.confirm", "delete"), keyHint("tui.select.cancel", "keep"),
    ], 0)}`, width, "…");
  }
  if (header.statusMessage) {
    return truncateToWidth(` ${theme.fg(header.statusMessage.type === "error" ? "error" : "accent", header.statusMessage.message)}`, width, "…");
  }
  // Ordered by importance; the tail is dropped on narrow terminals, "back" always stays last.
  const parts = [
    keyHint("tui.select.confirm", "resume"),
    keyHint("tui.input.tab", "scope"),
    keyHint("app.session.toggleSort", "sort"),
    keyHint("app.session.toggleNamedFilter", "named"),
    ...(header.showRenameHint ? [keyHint("app.session.rename", "rename")] : []),
    keyHint("app.session.delete", "delete"),
    keyHint("app.session.togglePath", header.showPath ? "hide path" : "path"),
    theme.fg("muted", 're:<pattern> regex · "phrase" exact'),
  ];
  const back = keyHint("tui.select.cancel", "back");
  for (let keep = parts.length; keep > 1; keep--) {
    const row = hintLine(theme, [...parts.slice(0, keep), back]);
    if (visibleWidth(row) <= width) return row;
  }
  return truncateToWidth(hintLine(theme, [parts[0], back]), width, "…");
}

const safeLine = (value: unknown) => stripTerminalSequences(String(value ?? ""))
  .replace(/[\x00-\x1f\x7f-\x9f]+/g, " ").replace(/\s+/g, " ").trim();
const firstLine = (content: string) => safeLine(content.split("\n").find(l => l.trim()) ?? "").replace(/\.$/, "");

/**
 * interactive-shell notifications have no renderer and print their raw model-facing text.
 * Show one line like pi-bg-tasks (✓ ✗ ■, ◆ for monitor events); Ctrl+O expands the full text.
 */
export function shellMessageLine(customType: string, content: string, details: any, theme: Theme): string {
  if (customType === "interactive-shell-monitor-event") {
    const where = [details?.sessionId, details?.triggerId].filter(Boolean).map(safeLine).join(" · ");
    return `${theme.fg("accent", "◆")} ${theme.fg("text", where || "monitor event")}${details?.lineOrDiff ? theme.fg("muted", ` · ${safeLine(details.lineOrDiff)}`) : ""}`;
  }
  const summary = theme.fg("text", firstLine(content) || customType.replace("interactive-shell-", ""));
  if (customType === "interactive-shell-update") return `${theme.fg("dim", "·")} ${summary}`;
  const reason = details?.state?.terminalReason;
  const exit = details?.exitCode ?? details?.completion?.exitCode;
  const failed = reason === "script-failed" || (typeof exit === "number" && exit !== 0) || details?.cancelled;
  const ok = !failed && exit === 0;
  return `${theme.fg(ok ? "success" : failed ? "error" : "warning", ok ? "✓" : failed ? "✗" : "■")} ${summary}`;
}

export default function uiPolish(pi: ExtensionAPI) {
  for (const customType of ["interactive-shell-monitor-event", "interactive-shell-monitor-lifecycle", "interactive-shell-transfer", "interactive-shell-update"]) {
    pi.registerMessageRenderer(customType, (message: any, options: any, theme: Theme) => ({
      render(width: number) {
        const content = typeof message.content === "string" ? message.content : "";
        const head = truncateToWidth(shellMessageLine(customType, content, message.details, theme), width, "…");
        if (!options.expanded) return [head];
        const body = stripTerminalSequences(content).replace(/[\x00-\x08\x0b-\x1f\x7f-\x9f]/g, "");
        return [head, ...new Text(theme.fg("muted", body), 2, 0).render(width)];
      },
      invalidate() {},
    }));
  }
  let restore: (() => void) | undefined;
  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui" || restore) return;
    const theme = () => ctx.ui.theme;
    const restores: Array<() => void> = [];
    const patch = <T extends object, K extends keyof T>(target: T, key: K, next: T[K]) => {
      const previous = target[key];
      target[key] = next;
      restores.push(() => { target[key] = previous; });
      return previous;
    };

    const prototype = ModelSelectorComponent.prototype;
    const original = prototype.render;
    const internals = prototype as any;
    const snapshot = internals.loadModelsFromSnapshot, filter = internals.filterModels;
    const refreshSelection = new WeakMap<object, { provider: string; id: string }>();
    if (typeof snapshot === "function" && typeof filter === "function") {
      patch(internals, "loadModelsFromSnapshot", function(this: any) {
        const selected = this.filteredModels?.[this.selectedIndex]?.model;
        if (selected) refreshSelection.set(this, selected);
        snapshot.call(this);
      });
      patch(internals, "filterModels", function(this: any, query: string) {
        filter.call(this, query);
        const selected = refreshSelection.get(this);
        refreshSelection.delete(this);
        if (!selected) return;
        const index = this.filteredModels.findIndex((item: any) => item.model.id === selected.id && item.model.provider === selected.provider);
        if (index >= 0) { this.selectedIndex = index; this.updateList(); }
      });
    }
    patch(prototype, "render", function(this: any, width: number) {
      const picker = this as any;
      // Fail back to native UI after a host upgrade instead of breaking model selection.
      if (!Array.isArray(picker.filteredModels) || !picker.searchInput ||
          typeof picker.modelRuntime?.isUsingSubscription !== "function") return original.call(this, width);
      const t = theme();
      this.clear();
      this.addChild(new Text(borderLine(t, width), 0, 0));
      this.addChild(new Text(titleLine(t, "Model", picker.scope === "scoped" ? "favorites" : "all"), 0, 0));
      this.addChild(picker.searchInput);
      for (const line of modelPickerLines(picker, width, t)) this.addChild(new Text(line, 0, 0));
      const hints = [keyHint("tui.select.confirm", "apply")];
      if (picker.scopedModels.length) hints.push(keyHint("tui.input.tab", "favorites/all"));
      if (picker.onSelectAsDefaultCallback) hints.push(keyHint("app.models.save", "save default"));
      hints.push(keyHint("tui.select.cancel", "back"));
      this.addChild(new Text(truncateToWidth(hintLine(t, hints), width), 0, 0));
      this.addChild(new Text(borderLine(t, width), 0, 0));
      return Container.prototype.render.call(this, width);
    });

    const treeProto = TreeSelectorComponent.prototype;
    const treeRender = treeProto.render, treeInput = treeProto.handleInput;
    const helpVisible = new WeakSet<object>();
    const treeRowLimits = new WeakMap<object, number>();
    patch(treeProto, "render", function(this: any, width: number) {
      const tree = this as any;
      const children = this.children;
      // shortcut: Pi 1.5.0 owns this child layout; fall back if a host upgrade changes it.
      if (!tree.treeList || children[7] !== tree.treeContainer || children[8] !== tree.labelInputContainer) {
        return treeRender.call(this, width);
      }
      const t = theme();
      const border = () => new Text(borderLine(t, width), 0, 0);
      const help = helpVisible.has(this) && !tree.labelInput ? children[3] : undefined;
      const footer = tree.labelInput ? undefined : new Text(truncateToWidth(hintLine(t, [
        keyHint("tui.select.confirm", "select"), keyHint("tui.select.cancel", "back"), rawKeyHint("f1", "help"),
      ]), width), 0, 0);
      const header = [border(), new Text(titleLine(t, "Session tree"), 0, 0), ...(tree.labelInput ? [] : [children[4]])];
      const tail = [...(help ? [help] : []), ...(footer ? [footer] : []), border()];
      const originalLimit = treeRowLimits.get(this) ?? tree.treeList.maxVisibleLines;
      treeRowLimits.set(this, originalLimit);
      const chrome = [...header, ...tail].reduce((n, child) => n + child.render(width).length, 0);
      tree.treeList.maxVisibleLines = Math.max(1, Math.min(originalLimit, originalLimit * 2 - chrome - 1));
      this.children = [...header, tree.labelInput ? tree.labelInputContainer : tree.treeContainer, ...tail];
      try { return normalizeChrome(Container.prototype.render.call(this, width), t); }
      finally { this.children = children; }
    });
    patch(treeProto, "handleInput", function(this: any, data: string) {
      if (!(this as any).labelInput && matchesKey(data, "f1")) {
        if (helpVisible.has(this)) helpVisible.delete(this); else helpVisible.add(this);
        return;
      }
      treeInput.call(this, data);
    });

    // pi-tui lists are shared by core menus, autocomplete and extension UIs (files, tasks, agents).
    const selectProto = SelectList.prototype as any;
    if (typeof selectProto.renderItem === "function") {
      const renderItem = selectProto.renderItem;
      patch(selectProto, "renderItem", function(this: any, ...args: any[]) { return focusMarker(renderItem.apply(this, args)); });
    }
    const settingsRender = SettingsList.prototype.render;
    patch(SettingsList.prototype, "render", function(this: any, width: number) {
      return normalizeChrome(settingsRender.call(this, width), theme());
    });

    // Core dialogs: same title/hint/marker format, no blank Spacer rows, grey borders.
    const confirmTitles = new WeakSet<object>();
    const sessionHeaders = new WeakSet<object>();
    const sessionFooters = new WeakMap<object, { render(width: number): string[]; invalidate(): void }>();
    const forkHeaders = new WeakSet<object>(); // headers rewritten once per component instance
    const prepare = new Map<Function, (component: any, t: Theme) => void>([
      [ExtensionSelectorComponent, (selector, t) => {
        // ui.confirm passes "title\nmessage"; only the first line is the title.
        const title: unknown = selector.baseTitle;
        if (confirmTitles.has(selector) || selector.countdown || typeof title !== "string" || !title.includes("\n")) return;
        const [first, ...rest] = title.split("\n");
        selector.titleText?.setText?.(`${t.fg("accent", t.bold(first))}\n${t.fg("muted", rest.join("\n"))}`);
        confirmTitles.add(selector);
      }],
      [SessionSelectorComponent, (selector, t) => {
        for (const child of selector.children) if (child instanceof DynamicBorder) child.color = (s: string) => t.fg("border", s);
        // The header class is internal; patch its prototype once, through the live instance.
        const proto = selector.header && Object.getPrototypeOf(selector.header);
        if (!proto || sessionHeaders.has(proto) || typeof proto.render !== "function") return;
        sessionHeaders.add(proto);
        const render = proto.render;
        patch(proto, "render", function(this: any, width: number) {
          return sessionLayout(this) ? [sessionTitleRow(this, width, theme())] : render.call(this, width);
        });
      }],
      [ThinkingSelectorComponent, (selector, t) => {
        if (forkHeaders.has(selector)) return;
        const [title, subtitle] = selector.children.filter((c: any) => c instanceof Text);
        title?.setText?.(titleLine(t, "Thinking level"));
        subtitle?.setText?.(t.fg("muted", ` ${plain(subtitle.text ?? "").trim()}`));
        forkHeaders.add(selector);
      }],
      [UserMessageSelectorComponent, (selector, t) => {
        if (forkHeaders.has(selector)) return;
        const [title] = selector.children.filter((c: any) => c instanceof Text);
        title?.setText?.(t.fg("accent", t.bold("Fork from message")));
        forkHeaders.add(selector);
      }],
    ]);
    // Dialogs Pi ships without a title or without a hint row get the missing house-style row.
    const settingsTitles = new WeakMap<object, Text>();
    const textDone = new WeakMap<object, string>();
    const fallbackHints = new Map<Function, (t: Theme) => string>([
      [UserMessageSelectorComponent, t => hintLine(t, [keyHint("tui.select.confirm", "fork"), keyHint("tui.select.cancel", "back")])],
      [OAuthSelectorComponent, t => hintLine(t, [keyHint("tui.select.confirm", "select"), keyHint("tui.select.cancel", "cancel")])],
    ]);
    const hasHintRow = (lines: string[]) => lines.some(l => /\S+ (back|cancel|close)\b/.test(plain(l)) && plain(l).includes(" · "));
    for (const component of [ExtensionSelectorComponent, ExtensionInputComponent, ThinkingSelectorComponent,
      ThemeSelectorComponent, SettingsSelectorComponent, OAuthSelectorComponent, LoginDialogComponent,
      SessionSelectorComponent, UserMessageSelectorComponent, ShowImagesSelectorComponent, ExtensionEditorComponent]) {
      const proto = component.prototype;
      const render = proto.render;
      patch(proto, "render", function(this: any, width: number) {
        const t = theme();
        prepare.get(component)?.(this, t);
        normalizeTextChildren(this, t, textDone);
        const children = this.children;
        let visible = children.filter((child: any) => !(child instanceof Spacer));
        // Fork renders its title above the top border; move the border first (Container keeps mouse rows right).
        if (component === UserMessageSelectorComponent) {
          const top = visible.findIndex((c: any) => c instanceof DynamicBorder);
          if (top > 0) visible = [visible[top], ...visible.slice(0, top), ...visible.slice(top + 1)];
        }
        if (component === SessionSelectorComponent && visible.includes(this.header) && sessionLayout(this.header) &&
            visible.at(-1) instanceof DynamicBorder) {
          const header = this.header;
          const footer = sessionFooters.get(this) ?? { render: (w: number) => [sessionHintRow(header, w, theme())], invalidate() {} };
          sessionFooters.set(this, footer);
          visible = [...visible.slice(0, -1), footer, visible.at(-1)];
        }
        if (component === SettingsSelectorComponent && visible[0] instanceof DynamicBorder) {
          const title = settingsTitles.get(this) ?? new Text("", 0, 0);
          settingsTitles.set(this, title);
          title.setText(titleLine(t, "Settings"));
          visible = [visible[0], title, ...visible.slice(1)];
        }
        this.children = visible;
        try {
          const lines = normalizeChrome(render.call(this, width), t);
          // Appended after the last interactive row, so native mouse rows above stay where they were.
          const fallback = fallbackHints.get(component);
          if (fallback && lines.length > 1 && /^─+$/.test(plain(lines[lines.length - 1])) && !hasHintRow(lines)) {
            lines.splice(lines.length - 1, 0, truncateToWidth(fallback(t), width));
          }
          return lines;
        } finally { this.children = children; }
      });
    }

    // Pi does not export these screens; their prototypes are patched the first time one is shown.
    // Line-preserving only (no Spacer removal): some of them map mouse rows themselves.
    const lazyNames = new Set(["TrustSelectorComponent", "ScopedModelsSelectorComponent", "McpManagerView",
      "ConfigSelectorComponent", "FirstTimeSetupComponent", "RadiusLoginMenuComponent",
      // Settings submenus (also normalized through SettingsList when nested there).
      "SelectSubmenu", "SteppedSubmenu", "ThemeSubmenu", "WarningSettingsSubmenu"]);
    const lazyDone = new Set<object>();
    const lazyPatch = (component: any) => {
      const proto = component && Object.getPrototypeOf(component);
      if (!proto || lazyDone.has(proto) || !lazyNames.has(proto.constructor?.name) || typeof proto.render !== "function") return;
      lazyDone.add(proto);
      const render = proto.render;
      patch(proto, "render", function(this: any, width: number) {
        const t = theme();
        normalizeTextChildren(this, t, textDone);
        return normalizeChrome(render.call(this, width), t);
      });
    };
    // Selectors and custom UIs enter the screen through Container.addChild (editorContainer).
    const addChild = Container.prototype.addChild;
    patch(Container.prototype, "addChild", function(this: any, component: any) {
      try { lazyPatch(component); } catch { /* presentation only */ }
      return addChild.call(this, component);
    });

    restore = () => { for (const undo of restores.reverse()) undo(); };
  });
  pi.on("session_shutdown", () => { restore?.(); restore = undefined; });
}
