import { execFileSync } from "node:child_process";
import { realpathSync } from "node:fs";
import { dirname, join } from "node:path";

export const hostModules =
  process.env.PI_TEST_HOST_MODULES ??
  join(dirname(realpathSync(execFileSync("/bin/sh", ["-c", "command -v pi"], { encoding: "utf8" }).trim())), "../lib/pi/node_modules");
