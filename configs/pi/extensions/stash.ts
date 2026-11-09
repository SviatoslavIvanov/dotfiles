import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

/** Alt+S swaps the editor with a stashed draft, so a quick question does not cost the long prompt being written. */
export default function stash(pi: ExtensionAPI) {
	let stashed = "";

	const show = (ctx: ExtensionContext) => ctx.ui.setStatus("stash", stashed ? ctx.ui.theme.fg("muted", "stash") : undefined);

	pi.registerShortcut("alt+s", {
		description: "Put the draft aside or bring it back",
		handler: async (ctx) => {
			const draft = ctx.ui.getEditorText();
			if (!draft.trim() && !stashed) return;
			ctx.ui.setEditorText(stashed);
			stashed = draft.trim() ? draft : "";
			show(ctx);
		},
	});

	// A new or resumed session clears extension statuses; the stash itself outlives it until Pi exits or reloads
	pi.on("session_start", async (_event, ctx) => {
		if (ctx.hasUI) show(ctx);
	});
}
