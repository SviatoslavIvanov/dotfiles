// sv-dark / sv-light: Catppuccin Mocha / Latte with the peach accent used by Zed and JankyBorders.
// Roles follow the Catppuccin style guide; panels are tints of the base; any readable token that
// misses its contrast floor on the base or a panel is moved toward the text colour until it passes.
// Usage: node generate-themes.mjs [themes-dir]
import fs from "fs";
import os from "os";
const PI = process.env.PI_TEST_HOST_MODULES
  ? `${process.env.PI_TEST_HOST_MODULES}/@earendil-works`
  : `${os.homedir()}/.pi/agent/install/releases/1.5.0/node_modules/@earendil-works`;
const { parseColor, colorToRgb, colorToHex, colorToOklch, oklchColor, mixColors } = await import(`${PI}/pi-tui/dist/index.js`);
const OUT = process.argv[2] ?? new URL("themes", import.meta.url).pathname;

const PALETTES = {
  dark: { // Mocha
    rosewater: "#f5e0dc", flamingo: "#f2cdcd", pink: "#f5c2e7", mauve: "#cba6f7", red: "#f38ba8", maroon: "#eba0ac",
    peach: "#fab387", yellow: "#f9e2af", green: "#a6e3a1", teal: "#94e2d5", sky: "#89dceb", sapphire: "#74c7ec",
    blue: "#89b4fa", lavender: "#b4befe", text: "#cdd6f4", subtext1: "#bac2de", subtext0: "#a6adc8",
    overlay2: "#9399b2", overlay1: "#7f849c", overlay0: "#6c7086", surface2: "#585b70", surface1: "#45475a",
    surface0: "#313244", base: "#1e1e2e", mantle: "#181825", crust: "#11111b",
  },
  light: { // Latte
    rosewater: "#dc8a78", flamingo: "#dd7878", pink: "#ea76cb", mauve: "#8839ef", red: "#d20f39", maroon: "#e64553",
    peach: "#fe640b", yellow: "#df8e1d", green: "#40a02b", teal: "#179299", sky: "#04a5e5", sapphire: "#209fb5",
    blue: "#1e66f5", lavender: "#7287fd", text: "#4c4f69", subtext1: "#5c5f77", subtext0: "#6c6f85",
    overlay2: "#7c7f93", overlay1: "#8c8fa1", overlay0: "#9ca0b0", surface2: "#acb0be", surface1: "#bcc0cc",
    surface0: "#ccd0da", base: "#eff1f5", mantle: "#e6e9ef", crust: "#dce0e8",
  },
};

// Token -> palette colour. Panels: [colour, tint amount over base].
const ROLES = {
  text: "text", userMessageText: "text", toolTitle: "text", searchMatchText: "text",
  muted: "subtext0", toolOutput: "subtext0", customMessageText: "subtext0", thinkingText: "overlay2",
  dim: "overlay1", mdLinkUrl: "overlay1",
  accent: "peach", borderAccent: "peach", mdHeading: "peach", mdListBullet: "peach",
  border: "overlay0", borderMuted: "surface1", mdHr: "overlay0", mdQuoteBorder: "overlay0", mdCodeBlockBorder: "overlay0",
  success: "green", error: "red", warning: "yellow", bashMode: "teal",
  mdLink: "blue", mdCode: "pink", mdCodeBlock: "subtext1", mdQuote: "overlay2",
  toolDiffAdded: "green", toolDiffRemoved: "red", toolDiffContext: "overlay2",
  customMessageLabel: "mauve",
  syntaxComment: "overlay2", syntaxKeyword: "mauve", syntaxFunction: "blue", syntaxVariable: "text",
  syntaxString: "green", syntaxNumber: "peach", syntaxType: "yellow", syntaxOperator: "sky", syntaxPunctuation: "overlay2",
  // Thinking ramp ends hot; the default effort (high) paints the editor border in the accent.
  thinkingOff: "overlay0", thinkingMinimal: "lavender", thinkingLow: "blue", thinkingMedium: "mauve",
  thinkingHigh: "peach", thinkingXhigh: "maroon", thinkingMax: "red",
  scrollbarTrack: "surface0", scrollbarThumb: "overlay0",
};
const PANELS = {
  dark: {
    userMessageBg: ["surface0", 1], selectedBg: ["surface1", 1],
    toolPendingBg: ["surface0", 0.6], toolSuccessBg: ["green", 0.2], toolErrorBg: ["red", 0.2],
    customMessageBg: ["lavender", 0.18], searchMatchBg: ["yellow", 0.25],
  },
  light: {
    userMessageBg: ["crust", 1], selectedBg: ["surface0", 1],
    toolPendingBg: ["crust", 0.7], toolSuccessBg: ["green", 0.2], toolErrorBg: ["red", 0.16],
    customMessageBg: ["lavender", 0.18], searchMatchBg: ["yellow", 0.25],
  },
};
// Surfaces each token is drawn on, besides the base.
const CONTENT = ["userMessageBg", "customMessageBg", "toolPendingBg", "toolSuccessBg", "toolErrorBg"];
const ON = { text: [...CONTENT, "selectedBg"], accent: [...CONTENT, "selectedBg"], muted: [...CONTENT, "selectedBg"], searchMatchText: ["searchMatchBg"] };
const DECORATIVE = new Set(["border", "borderMuted", "mdHr", "mdQuoteBorder", "mdCodeBlockBorder", "scrollbarTrack", "scrollbarThumb", "thinkingOff"]);
const FLOOR = { dim: 3, thinkingMinimal: 3 }; // everything else readable: WCAG AA 4.5

const rgb = (v) => colorToRgb(parseColor(v));
const lum = (v) => { const { r, g, b } = rgb(v); const f = (c) => { c /= 255; return c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4; }; return 0.2126 * f(r) + 0.7152 * f(g) + 0.0722 * f(b); };
const contrast = (a, b) => { const [x, y] = [lum(a), lum(b)]; return (Math.max(x, y) + 0.05) / (Math.min(x, y) + 0.05); };
// sRGB mix = alpha overlay; OKLCH would drag the hue through blue on the way from base to green/red.
const mix = (a, b, t) => colorToHex(mixColors(parseColor(a), parseColor(b), t, "srgb"));

for (const mode of ["dark", "light"]) {
  const p = PALETTES[mode];
  const panels = Object.fromEntries(Object.entries(PANELS[mode]).map(([k, [c, t]]) => [k, t === 1 ? p[c] : mix(p.base, p[c], t)]));
  const colors = {};
  for (const [token, name] of Object.entries(ROLES)) {
    let hex = p[name];
    const floor = FLOOR[token] ?? 4.5;
    const surfaces = [p.base, ...(ON[token] ?? CONTENT).map((k) => panels[k])];
    // Latte accents (peach, yellow, sky) are too pale for text: change only OKLab lightness until readable.
    const { l, c, h } = colorToOklch(parseColor(hex));
    const step = mode === "dark" ? 0.005 : -0.005;
    for (let i = 1; !DECORATIVE.has(token) && i < 200 && Math.min(...surfaces.map((s) => contrast(hex, s))) < floor; i++)
      hex = colorToHex(oklchColor(Math.min(1, Math.max(0, l + step * i)), c, h));
    colors[token] = hex;
  }
  Object.assign(colors, panels);
  const theme = {
    $schema: "https://pi.dev/schemas/theme.schema.json",
    name: `sv-${mode}`,
    appearance: mode,
    colors: Object.fromEntries(Object.keys(colors).sort().map((k) => [k, colors[k]])),
    export: { pageBg: p.base, cardBg: p.mantle, infoBg: panels.searchMatchBg },
  };
  fs.writeFileSync(`${OUT}/sv-${mode}.json`, JSON.stringify(theme, null, 2) + "\n");
  console.log(`sv-${mode}: Catppuccin ${mode === "dark" ? "Mocha" : "Latte"}, peach accent`);
}
