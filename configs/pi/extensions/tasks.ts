import { getSelectListTheme, keyHint, rawKeyHint, type ExtensionAPI, type ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import { Input, SelectList, Text, matchesKey, stripTerminalSequences, truncateToWidth } from "@earendil-works/pi-tui";
import { borderLine, hintLine, titleLine } from "./ui-polish.ts";

// Managers own execution and cleanup. This bus carries only local UI snapshots/actions.
export const TASKS_COLLECT = "sv:tasks:collect";
export interface Task {
  id: string;
  kind: "agent" | "bash" | "shell" | "monitor";
  label: string;
  status: string;
  active: boolean;
  read?: () => string;
  open?: (ctx: ExtensionCommandContext) => Promise<void>;
  stop?: () => void | Promise<void>;
}
export interface TaskRequest { tasks: Task[] }
export const taskKey = (task: Task) => `${task.kind}:${task.id}`;
export const safeText = (value: string) => stripTerminalSequences(value)
  .replace(/[\x00-\x08\x0b-\x1f\x7f-\x9f]/g, "").replace(/\t/g, "  ");
const singleLine = (value: string) => safeText(value).replace(/\s+/g, " ").trim();

export function collectTasks(pi: Pick<ExtensionAPI, "events">): Task[] {
  const request: TaskRequest = { tasks: [] };
  pi.events.emit(TASKS_COLLECT, request);
  return request.tasks.sort((a, b) => Number(b.active) - Number(a.active) || taskKey(a).localeCompare(taskKey(b)));
}

async function pickTask(ctx: ExtensionCommandContext, collect: () => Task[], kind?: string, selected?: string) {
  return ctx.ui.custom<string | undefined>((tui, theme, kb, done) => {
    const input = new Input();
    let list: SelectList;
    let tasks: Task[] = [];
    let active = 0;
    let signature = "";
    const update = () => {
      const all = collect().filter(t => !kind || t.kind === kind);
      active = all.filter(t => t.active).length;
      tasks = all.filter(t =>
        singleLine(`${t.kind} ${t.id} ${t.label} ${t.status}`).toLowerCase().includes(input.getValue().toLowerCase()));
      const items = tasks.map(t => ({ value: taskKey(t), label: `${t.active ? "●" : "○"} ${t.kind} · ${singleLine(t.label)}`, description: singleLine(t.status) }));
      const next = JSON.stringify([items, tui.terminal.rows]);
      if (next === signature) return;
      signature = next;
      const previous = list?.getSelectedItem()?.value ?? selected;
      list = new SelectList(items, Math.max(1, Math.min(8, tui.terminal.rows - 8)), getSelectListTheme());
      const index = items.findIndex(i => i.value === previous);
      if (index >= 0) list.setSelectedIndex(index);
      list.onSelect = item => done(item.value);
      list.onCancel = () => done(undefined);
    };
    update();
    const timer = setInterval(() => { update(); tui.requestRender(); }, 1000);
    timer.unref();
    return {
      get focused() { return input.focused; },
      set focused(value: boolean) { input.focused = value; },
      render(width: number) {
        update();
        return [
          borderLine(theme, width),
          titleLine(theme, "Tasks", `${kind ? `${kind} · ` : ""}${active} active`),
          ...input.render(width),
          ...(tasks.length ? list.render(width) : [theme.fg("muted", "  No matching tasks")]),
          hintLine(theme, [keyHint("tui.select.confirm", "open"), keyHint("tui.select.cancel", "back")]),
          borderLine(theme, width),
        ].map(l => truncateToWidth(l, width));
      },
      handleInput(data: string) {
        if (kb.matches(data, "tui.select.cancel")) return done(undefined);
        if (["tui.select.up", "tui.select.down", "tui.select.confirm"].some(k => kb.matches(data, k as any))) {
          if (tasks.length) list.handleInput(data);
        } else { input.handleInput(data); update(); }
        tui.requestRender();
      },
      invalidate() { signature = ""; input.invalidate(); list?.invalidate(); },
      dispose() { clearInterval(timer); },
    };
  });
}

async function viewOutput(ctx: ExtensionCommandContext, getTask: () => Task | undefined): Promise<void> {
  await ctx.ui.custom<void>((tui, theme, kb, done) => {
    let offset = 0, follow = true, max = 0;
    const timer = setInterval(() => tui.requestRender(), 1000);
    timer.unref();
    return {
      render(width: number) {
        const task = getTask();
        let output: string;
        try { output = task?.read?.() ?? "Task is no longer available."; }
        catch (error) { output = `Cannot read output: ${String(error)}`; }
        output = safeText(output);
        if (output.length > 32768) output = `${output.slice(0, 1024)}\n…[truncated]…\n${output.slice(-30720)}`;
        const lines = new Text(output, 1, 0).render(width);
        const height = Math.max(1, Math.min(24, tui.terminal.rows - 7));
        max = Math.max(0, lines.length - height);
        offset = follow ? max : Math.min(offset, max);
        return [
          borderLine(theme, width),
          titleLine(theme, task ? `${task.kind} · ${singleLine(task.label)}` : "Output"),
          theme.fg("muted", ` ${singleLine(task?.status ?? "unavailable")}${follow ? " · following output" : ""}`),
          ...lines.slice(offset, offset + height),
          hintLine(theme, [rawKeyHint("↑↓", "scroll"), rawKeyHint("pgup/pgdn", "page"), rawKeyHint("end", "follow"), keyHint("tui.select.cancel", "back")]),
          borderLine(theme, width),
        ].map(l => truncateToWidth(l, width));
      },
      handleInput(data: string) {
        if (kb.matches(data, "tui.select.cancel")) return done();
        const page = Math.max(1, Math.min(24, tui.terminal.rows - 7));
        if (kb.matches(data, "tui.select.up")) { follow = false; offset = Math.max(0, offset - 1); }
        else if (kb.matches(data, "tui.select.down")) { offset = Math.min(max, offset + 1); follow = offset === max; }
        else if (matchesKey(data, "pageUp")) { follow = false; offset = Math.max(0, offset - page); }
        else if (matchesKey(data, "pageDown")) { offset = Math.min(max, offset + page); follow = offset === max; }
        else if (matchesKey(data, "home")) { follow = false; offset = 0; }
        else if (matchesKey(data, "end")) follow = true;
        tui.requestRender();
      },
      invalidate() {},
      dispose() { clearInterval(timer); },
    };
  });
}

export async function runTasks(pi: ExtensionAPI, ctx: ExtensionCommandContext, kind?: string) {
  if (ctx.mode !== "tui") { ctx.ui.notify("Tasks requires terminal mode.", "warning"); return; }
  let selected: string | undefined;
  const collect = () => collectTasks(pi);
  while (true) {
    selected = await pickTask(ctx, collect, kind, selected);
    if (!selected) return;
    const getTask = () => collect().find(t => taskKey(t) === selected);
    const task = getTask();
    if (!task) { ctx.ui.notify("Task is no longer available.", "warning"); continue; }
    const actions = [
      ...(task.open ? [task.kind === "agent" ? "Open conversation" : "Attach terminal"] : []),
      ...(task.read ? ["View output / events"] : []),
      ...(task.active && task.stop ? ["Stop task…"] : []),
    ];
    const action = await ctx.ui.select(`${task.kind} · ${singleLine(task.label)}`, actions);
    try {
      // Resolve again: tasks may finish or disappear while a menu is open.
      const current = getTask();
      if (!current) continue;
      if (action === "View output / events") await viewOutput(ctx, getTask);
      else if (action === "Open conversation" || action === "Attach terminal") await current.open?.(ctx);
      else if (action === "Stop task…" && current.active &&
        await ctx.ui.confirm("Stop task?", `${current.kind} · ${singleLine(current.label)}\nClosing a viewer does not stop a task. This action does.`)) {
        const live = getTask();
        if (live?.active) await live.stop?.();
      }
    } catch (error) { ctx.ui.notify(`Task action failed: ${String(error)}`, "error"); }
  }
}

export default function tasks(pi: ExtensionAPI) {
  pi.registerCommand("tasks", {
    description: "Open agents, shell sessions, monitors and bash logs",
    handler: (args, ctx) => runTasks(pi, ctx, args.trim() || undefined),
  });
  pi.registerShortcut("ctrl+shift+t", {
    description: "Open background tasks",
    handler: ctx => runTasks(pi, ctx as ExtensionCommandContext),
  });
  pi.events.on("sv:tasks:open", (request: any) => {
    request.open = () => runTasks(pi, request.ctx, request.kind);
  });
}
