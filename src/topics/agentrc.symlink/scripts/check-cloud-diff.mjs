#!/usr/bin/env node
// Untrusted-diff gate for a branch pushed by a cloud session.
//
//   node check-cloud-diff.mjs <branch> [--base origin/main] [--allow <path>]...
//
// Run from the repo root after `git fetch`. It reads git objects only and never
// checks out or runs anything from the branch. Protected paths come from
// `.agents/cloud/protected-paths` on the base, so a branch can't loosen its own
// gate; a missing or empty list fails closed. On PASS the last line names the
// exact commit that was gated: review, validate and open the PR at that SHA.
import { execFileSync } from "node:child_process";

const args = process.argv.slice(2);
const branch = args[0];
if (!branch || branch.startsWith("--")) {
  console.error("usage: check-cloud-diff.mjs <branch> [--base origin/main] [--allow <path>]...");
  process.exit(2);
}
let base = "origin/main";
const allowed = new Set();
for (let i = 1; i < args.length; i += 2) {
  if (args[i] === "--base") base = args[i + 1];
  else if (args[i] === "--allow") allowed.add(args[i + 1]);
  else {
    console.error(`unknown option ${args[i]}`);
    process.exit(2);
  }
}

const git = (...gitArgs) => execFileSync("git", gitArgs, { maxBuffer: 256 * 1024 * 1024 });
const gitText = (...gitArgs) => git(...gitArgs).toString("utf8");

const ref = branch.startsWith("cloud/") || branch.startsWith("claude/") ? `origin/${branch}` : branch;
const head = gitText("rev-parse", "--verify", `${ref}^{commit}`).trim();
const mergeBase = gitText("merge-base", base, head).trim();

const failures = [];
const warnings = [];

let rules = [];
try {
  rules = gitText("show", `${base}:.agents/cloud/protected-paths`)
    .split("\n")
    .map((line) => line.trim())
    .filter((line) => line && !line.startsWith("#"));
} catch {
  // handled below: no rules means fail closed
}
if (!rules.length) failures.push(`no protected-path rules in ${base}:.agents/cloud/protected-paths`);

const isProtected = (path) =>
  rules.some((rule) => {
    if (rule.startsWith("basename:")) return path.split("/").pop() === rule.slice(9);
    if (rule.endsWith("/")) return path.startsWith(rule);
    return path === rule;
  });

// -z keeps unusual file names literal instead of quoted.
const fields = gitText("diff", "--name-status", "--no-renames", "-z", mergeBase, head).split("\0").filter(Boolean);
const changed = [];
for (let i = 0; i < fields.length; i += 2) changed.push([fields[i], fields[i + 1]]);

for (const [status, path] of changed) {
  if (isProtected(path) && !allowed.has(path)) failures.push(`protected path ${status} ${path}`);
  if (path === "pnpm-lock.yaml" || path.endsWith("package.json")) warnings.push(`dependency manifest changed: ${path}`);
  if (/vitest\.config|jest\.config|coverage/i.test(path)) warnings.push(`test or coverage config changed: ${path}`);
}

// Secret-looking strings. Patterns, not just gitleaks: gitleaks allowlists
// well-known example keys. Whole files are scanned, not diff lines, so nothing
// hides behind patch syntax.
const secretPatterns = [
  ["AWS access key", /AKIA[0-9A-Z]{16}/],
  ["private key", /-----BEGIN [A-Z ]*PRIVATE KEY-----/],
  ["Stripe live key", /\b[rs]k_live_[0-9A-Za-z]{10,}/],
  ["Anthropic key", /sk-ant-[0-9A-Za-z_-]{20,}/],
  ["OpenAI key", /\bsk-(proj-)?[0-9A-Za-z_-]{32,}/],
  ["GitHub token", /\bgh[pousr]_[0-9A-Za-z]{30,}/],
  ["Slack token", /\bxox[abprs]-[0-9A-Za-z-]{10,}/],
  ["JWT", /\beyJ[0-9A-Za-z_-]{20,}\.[0-9A-Za-z_-]{20,}\.[0-9A-Za-z_-]{10,}/],
  ["assigned secret", /(SERVICE_ROLE|SECRET|PRIVATE)_?KEY\s*[:=]\s*["']?[0-9A-Za-z_\-+/]{16,}/],
];
const scan = (text, where) => {
  for (const [name, pattern] of secretPatterns) if (pattern.test(text)) failures.push(`${name} in ${where}`);
};
for (const [status, path] of changed) {
  if (status === "D") continue;
  const blob = git("show", `${head}:${path}`);
  if (blob.includes(0)) {
    warnings.push(`binary file ${status} ${path}: check it by eye`);
    continue;
  }
  scan(blob.toString("utf8"), path);
}

const commits = gitText("log", "-z", "--format=%H%x1f%B", `${mergeBase}..${head}`)
  .split("\0")
  .filter((entry) => entry.trim())
  .map((entry) => {
    const [sha, message] = entry.split("\x1f");
    return { sha, message };
  });
for (const { sha, message } of commits) scan(message, `commit message ${sha.slice(0, 8)}`);
if (!commits.length) failures.push("branch has no commits beyond the base");
else if (commits[0].message.split("\n")[0].trim() !== "cloud: report") warnings.push("tip commit is not the cloud: report commit");
if (commits.some(({ message }) => /Co-Authored-By:.*(Claude|anthropic)/i.test(message))) {
  warnings.push("a commit carries an agent attribution trailer");
}

for (const warning of [...new Set(warnings)]) console.log(`WARN ${warning}`);
for (const failure of [...new Set(failures)]) console.log(`FAIL ${failure}`);
if (failures.length) process.exit(1);
console.log(`PASS ${changed.length} files, ${commits.length} commits, base ${mergeBase.slice(0, 8)}`);
console.log(`GATED ${head}`);
