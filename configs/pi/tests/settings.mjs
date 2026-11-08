import assert from "node:assert/strict";
import { mkdtempSync, writeFileSync, readFileSync, statSync, symlinkSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";

const root = fileURLToPath(new URL("../", import.meta.url));
const dir = mkdtempSync(join(tmpdir(), "pi-settings-"));
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
try {
  const installer = join(dir, "installer-pi"), nixPi = join(dir, "nix-pi"), launcher = join(dir, "pi");
  writeFileSync(installer, "#!/bin/sh\nexit 0\n", { mode: 0o700 });
  writeFileSync(nixPi, "#!/bin/sh\nexit 0\n", { mode: 0o700 });
  const retire = (binary = nixPi) => spawnSync("bash", [join(root, "prefer-nix.sh"), launcher, installer, binary], { encoding: "utf8" });
  symlinkSync("installer-pi", launcher);
  assert.notEqual(retire(join(dir, "missing-nix")).status, 0);
  assert.ok(statSync(launcher));
  assert.equal(retire().status, 0);
  assert.equal(readFileSync(`${launcher}.pi-installer-backup`, "utf8"), readFileSync(installer, "utf8"));
  assert.equal(retire().status, 0, "retirement is idempotent");
  symlinkSync("installer-pi", launcher);
  assert.notEqual(retire().status, 0, "never overwrite a backup");
  rmSync(launcher);
  symlinkSync("nix-pi", launcher);
  assert.equal(retire().status, 0, "leave unrelated symlinks alone");
  assert.equal(readFileSync(launcher, "utf8"), readFileSync(nixPi, "utf8"));
  rmSync(launcher);
  writeFileSync(launcher, "user-owned launcher");
  assert.equal(retire().status, 0, "leave regular launchers alone");
  assert.equal(readFileSync(launcher, "utf8"), "user-owned launcher");
  console.log("OK: exact extension versions and guarded, reversible, idempotent Nix launcher migration");
} finally {
  rmSync(dir, { recursive: true, force: true });
}
