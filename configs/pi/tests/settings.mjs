import assert from "node:assert/strict";
import { mkdtempSync, writeFileSync, readFileSync, statSync, symlinkSync, readdirSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";

const root = fileURLToPath(new URL("../", import.meta.url));
const dir = mkdtempSync(join(tmpdir(), "pi-settings-"));
const target = join(dir, "settings.json");
const managed = join(root, "settings.json");
const expected = JSON.parse(readFileSync(managed, "utf8"));
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
const merge = () => spawnSync("bash", [join(root, "merge-settings.sh"), target, managed], { encoding: "utf8" });
const read = () => JSON.parse(readFileSync(target, "utf8"));
try {
  assert.equal(merge().status, 0);
  assert.deepEqual(read(), expected);
  assert.equal(statSync(target).mode & 0o777, 0o600);
  writeFileSync(target, JSON.stringify({ deviceId: "local-only", defaultModel: "old", packages: ["old"], extra: true }));
  assert.equal(merge().status, 0);
  assert.deepEqual(read(), { deviceId: "local-only", ...expected, extra: true });
  const before = readFileSync(target, "utf8");
  assert.equal(merge().status, 0);
  assert.equal(readFileSync(target, "utf8"), before);
  for (const invalid of ["{broken", "", "[]", "null", "{}\n{}"]) {
    writeFileSync(target, invalid);
    assert.notEqual(merge().status, 0);
    assert.equal(readFileSync(target, "utf8"), invalid);
    assert.deepEqual(readdirSync(dir), ["settings.json"]);
  }
  rmSync(target);
  const old = join(dir, "old.json");
  writeFileSync(old, '{"deviceId":"symlink-state"}');
  symlinkSync(old, target);
  assert.equal(merge().status, 0);
  assert.equal(read().deviceId, "symlink-state");
  assert.equal(readFileSync(old, "utf8"), '{"deviceId":"symlink-state"}');
  assert.equal(statSync(target).mode & 0o777, 0o600);
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
  console.log("OK: settings merge/permissions and guarded, reversible, idempotent Nix launcher migration");
} finally {
  rmSync(dir, { recursive: true, force: true });
}
