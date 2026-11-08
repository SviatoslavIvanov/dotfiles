import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

const root = fileURLToPath(new URL("../", import.meta.url));
const expected = JSON.parse(readFileSync(join(root, "settings.json"), "utf8"));
const manifest = JSON.parse(readFileSync(join(root, "npm/package.json"), "utf8"));
const lock = JSON.parse(readFileSync(join(root, "npm/package-lock.json"), "utf8"));
assert.deepEqual(lock.packages[""].dependencies, manifest.dependencies);
for (const entry of expected.packages) {
  const source = typeof entry === "string" ? entry : entry.source;
  const match = /^npm:(.+)@(\d+\.\d+\.\d+)$/.exec(source);
  assert.ok(match, "all extension versions must be exact");
  assert.equal(manifest.dependencies[match[1]], match[2]);
  assert.equal(lock.packages[`node_modules/${match[1]}`].version, match[2]);
}
console.log("OK: exact extension versions agree across settings, manifest and lock");
