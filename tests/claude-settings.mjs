import assert from "node:assert/strict";
import { mkdtempSync, writeFileSync, readFileSync, statSync, lstatSync, symlinkSync, readdirSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";

const script = fileURLToPath(new URL("../configs/claude-code/merge-settings.sh", import.meta.url));
const dir = mkdtempSync(join(tmpdir(), "claude-settings-"));
const target = join(dir, "settings.json");
const managed = join(dir, "managed.json");
const declared = {
  permissions: { defaultMode: "bypassPermissions" },
  sandbox: { enabled: false },
  attribution: { commit: "", pr: "" },
};
const local = {
  permissions: {
    defaultMode: "default",
    deny: ["Read(.env)", "Bash(rm:*)"],
    allow: ["Bash(git status)"],
    ask: ["Bash(git push:*)"],
    additionalDirectories: ["../notes"],
  },
  sandbox: { enabled: true, network: { deniedDomains: ["example.invalid"] } },
  attribution: { commit: "old", pr: "old", extra: true },
  enabledPlugins: { "local-plugin": true },
  unknown: ["preserve"],
};
const expected = {
  ...local,
  permissions: { ...local.permissions, ...declared.permissions },
  sandbox: { ...local.sandbox, ...declared.sandbox },
  attribution: { ...local.attribution, ...declared.attribution },
};
const merge = () => spawnSync("bash", [script, target, managed], { encoding: "utf8" });
const read = () => JSON.parse(readFileSync(target, "utf8"));
const putManaged = () => writeFileSync(managed, JSON.stringify(declared));
try {
  putManaged();
  assert.equal(merge().status, 0);
  assert.deepEqual(read(), declared);
  assert.equal(statSync(target).mode & 0o777, 0o600);

  writeFileSync(target, JSON.stringify(local));
  assert.equal(merge().status, 0);
  assert.deepEqual(read(), expected);
  const before = readFileSync(target, "utf8");
  assert.equal(merge().status, 0);
  assert.equal(readFileSync(target, "utf8"), before);

  for (const invalid of ["{broken", "", "[]", "null", "{}\n{}", "true"]) {
    writeFileSync(target, invalid);
    assert.notEqual(merge().status, 0);
    assert.equal(readFileSync(target, "utf8"), invalid);
    assert.deepEqual(readdirSync(dir).sort(), ["managed.json", "settings.json"]);

    writeFileSync(target, before);
    writeFileSync(managed, invalid);
    assert.notEqual(merge().status, 0);
    assert.equal(readFileSync(target, "utf8"), before);
    putManaged();
  }

  rmSync(target);
  const old = join(dir, "old.json");
  const original = JSON.stringify(local);
  writeFileSync(old, original);
  symlinkSync(old, target);
  assert.equal(merge().status, 0);
  assert.equal(lstatSync(target).isSymbolicLink(), false);
  assert.deepEqual(read(), expected);
  assert.equal(readFileSync(old, "utf8"), original);
  assert.equal(statSync(target).mode & 0o777, 0o600);

  rmSync(target);
  writeFileSync(old, "broken");
  symlinkSync(old, target);
  assert.notEqual(merge().status, 0);
  assert.equal(lstatSync(target).isSymbolicLink(), true);
  assert.equal(readFileSync(old, "utf8"), "broken");

  rmSync(target);
  rmSync(old);
  symlinkSync(old, target);
  assert.notEqual(merge().status, 0);
  assert.equal(lstatSync(target).isSymbolicLink(), true);
  assert.deepEqual(readdirSync(dir).sort(), ["managed.json", "settings.json"]);
  console.log("OK: recursive merge, permission rules, idempotence, mode 0600, invalid JSON, safe symlink migration");
} finally {
  rmSync(dir, { recursive: true, force: true });
}
