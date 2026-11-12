---
name: audit
description: Codebase health audit for any project. Runs review lenses (security and authorisation, data layer, database, performance, privacy, architecture, test estate, mobile release safety, internal tooling, delivery tooling, agent tooling) through lightweight subagents, hand-verifies what matters, has the other model family review the draft tickets, dedupes against doto and files tickets an agent can pick up. Use when the user asks for an audit, a full review, a health check or a pre-release review. A project's own audit command or `## Audit` section extends this with project nuances.
---

# audit

Review a codebase through several lenses, verify the findings, and land every one of them in doto as a ticket with enough detail for an agent to fix it. The audit reports and files tasks. It does not fix code.

## Step 0: Find the project overlay

A project extends this skill; it does not replace it. Look for, in order:

1. A project audit command or skill (for example `.claude/commands/audit.md` or `.claude/skills/audit/SKILL.md`). If you were invoked through it, you already have it.
2. An `## Audit` section in the project's `AGENTS.md` or `CLAUDE.md`.

The overlay supplies project facts and wins wherever it disagrees with this file. The things an overlay may define:

- **Known-state file**: where "already fixed, do not re-flag", "accepted" and "known open" findings live, and the date of the last run.
- **Lens agents**: project subagents that replace a generic lens prompt (for example an RLS auditor), with their tool-call budgets.
- **Pre-flight commands**: how to check the environment, run the baseline validation, build safely, and what must never be touched (staging, production, shared local databases).
- **Bug classes**: greps for patterns that have already reached production in this project.
- **Filing rules**: doto project, tags, and what counts as mechanical work.
- **Run recording**: any command that records the run for a maintenance tracker.

With no overlay, run the generic flow and offer at the end to write one from what you learnt (see Step 8).

## Step 1: Resolve scope and lenses

Arguments carry a **scope**, a **lens selection**, and free-text **extra instructions**. Do not confuse them.

- **Scope**: `full` (whole repository), nothing (incremental: everything changed since the known-state file's last-run date, or the last 30 days if there is none), or a narrowing such as `only src/app/admin`.
- **Lenses**: default for an incremental run is `security,data,database,performance,tooling`. `full` runs every lens that applies to the project (`mobile` only where there is a native app; `internal-tools` only where there are local admin tools, a sizeable scripts folder, a self-hosted CI runner or cloud agents). The user can name a subset (`/audit privacy architecture`).
- Anything else is an extra instruction layered on top. Never hand free text to a subagent as if it were a file list.

Build scope files in the session scratchpad (one path per line, tests excluded, deleted files filtered out) and pass each subagent the path, not an inline list. For an incremental run derive them from `git log --since=<date> --name-only`.

Resolve the doto project the way `next-task` does (argument, a `doto project:` line, then ask doto).

## Step 2: Pre-flight (orchestrator, no subagents)

1. **Notes first.** Open the project's memory or gotcha notes that match what you are about to do (building, shell helpers, database access) before doing it; an index line is not the note. Twice in the run that produced this skill, a mistake was made whose fix was already written down.
2. **Environment.** Confirm the machine is online (doto, the package registry). If not, run in offline mode and list what was skipped. Check for a running dev server before building.
3. **Baseline.** Run the project's quick validation in the background and record pass or fail, counts and wall time. A red baseline is a finding.
4. **Build.** If the overlay gives a safe build command, run it so server/client boundaries and registered endpoints are checked. Never build or query against a non-local environment.
5. **Re-verify known-open findings** against current code with greps and reads. Anything fixed moves to "now resolved" and is not handed to subagents as open. This is what stops the known-state file rotting.
6. **Bug-class sweep.** Run each overlay grep and read every hit. Hand hits to the relevant lens as named leads.
7. **Load open doto tasks** for the project once (titles and ids), ready for the dedupe in Step 6.

## Step 3: Run the lenses

| Lens             | Prompt                       | Covers                                                                                           |
| ---------------- | ---------------------------- | ------------------------------------------------------------------------------------------------ |
| `security`       | `lenses/authz.md`            | Pages, layouts and route handlers: gates, tenant scoping, public endpoints, webhooks, crons      |
| `data`           | `lenses/data-layer.md`       | Server actions and data access: identity trust, privileged clients, validation, email, payments  |
| `database`       | `lenses/database.md`         | Schema, grants, row-level policies, functions, storage rules, live catalogue checks              |
| `performance`    | `lenses/performance.md`      | Unbounded reads, N+1, queues, caching, bundle, hot paths                                         |
| `privacy`        | `lenses/privacy.md`          | Data inventory, retention and erasure, third-party flows, consent, promises checked against code |
| `architecture`   | `lenses/architecture.md`     | Layering, cycles, legacy locations, oversized files, duplication, change hotspots                |
| `testing`        | `lenses/test-estate.md`      | What a green run does not prove: coverage exclusions, gate tests, e2e gaps, flakes               |
| `mobile`         | `lenses/mobile-release.md`   | Native app: release config, over-the-air updates, permissions, lock, on-device data, recovery    |
| `internal-tools` | `lenses/internal-tooling.md` | Local admin tools, repo scripts, self-hosted runners, release gates, the agent trust boundary    |
| `tooling`        | orchestrator (Step 4)        | CI, dependencies, config hygiene, docs drift                                                     |
| `agents`         | orchestrator (Step 4)        | Skills, commands, subagents, hooks: stale, duplicated or unenforced                              |

Where the overlay names a project agent for a lens, use it and give it the lens prompt's checklist as extra instructions. Otherwise launch a general-purpose subagent with the lens file as its brief.

**Write one shared context file first** (in the scratchpad) and have every subagent read it before its lens file, so each prompt stays short and no lens re-reports what is known. It holds: the hard rules below; the stack and where the conventions file is; the dates and production scale to judge against, and the instruction that every finding says when it bites and whether it is a pre-release fix or can wait; the list of things already tracked in doto, by id, that must not be re-reported; and what a good finding looks like (severity, `file:line`, failure chain, a fix naming an existing exemplar, how to verify, verified or unverified). Each lens prompt then adds only its scope file, its project-specific leads and what earlier lenses already found.

Rules for every subagent, restated in the context file and in every prompt:

- Lightweight model (`model: sonnet`; `haiku` for pure lookups). Never let one inherit the top-level model.
- **At most three running at once.** Launch the next into a slot as one finishes.
- It must not spawn subagents. Read-only. Never touch staging or production, never reset a shared database, never run anything that takes a project-wide lock unless the overlay says how.
- An explicit tool-call budget (60 to 90), with the instruction to **use most of it**. Grep first, read the hits. A reviewer told only its ceiling may stop at a fifth of it and call the rest "not reached"; one told that stopping early is not acceptable does not.
- Give it the known-state path, the findings other lenses have already reported (so it does not repeat them), and the pre-flight leads.
- Require a closing **coverage statement** naming what it did not reach.

**Split large scopes.** A subagent reads perhaps 30 to 40 files properly. If a lens's scope has more than about 120 files, split it by directory before launching (for example shared library code, user and permissions modules, route-colocated actions). When a coverage statement lists high-risk files as "not reached", send a second pass over exactly those files. Treat "not reached" as unaudited, never as clean. The same goes for a subagent that finishes far under its budget: check how many tool calls it used, and if a lens reports "nothing critical" having read a fraction of its scope, re-run it over the remainder before the report is final. Whole-scope scans prove only the classes they scan for.

## Step 4: Orchestrator lenses

Done directly; they are a handful of reads and are where a periodic run earns its keep.

**Tooling and delivery confidence.** What CI actually runs on a pull request and what only runs on a laptop; dependency automation, `audit` and `outdated` results, and whether any override's "drop when" condition has been met; test-file counts and coverage thresholds; security headers; error-reporting configuration; environment validation; type-checker strictness; git hooks; the project's own doctor or health script; claims in the docs about scripts, jobs or files that no longer exist. Each recommendation must name the failure it would have caught here.

**Agent tooling.** Read the project's commands, skills, subagent definitions, hooks and local instruction files, with their last-modified dates, and look for:

- recipes that contradict the current conventions file (the classic: a scaffolding skill that teaches a pattern a lint rule now bans);
- skills whose job no longer exists;
- the same shell snippet (locks, worktrees, environment setup) copied into several files, especially where the copies have drifted;
- rules that are written down but not enforced by a hook or lint rule;
- subagents missing a tool they needed in this run;
- anything this run had to improvise that should be a script, a hook or a line in the overlay;
- generic skills that belong in `~/.agentrc/skills` with a project overlay.

## Step 5: Merge and verify

1. Deduplicate across lenses; keep one entry and note which lenses found it.
2. **Hand-verify every CRITICAL and HIGH** by reading the cited code, and where a database is involved, by reproducing it locally inside a transaction you roll back. Mark each verified or unverified. Trace the consequence one step further than the subagent did: a finding's real severity is usually decided by who else trusts the thing that is wrong.
3. Downgrade severities you cannot justify, and say why. Missing capability is not the same as a leak.
4. **Check the cheap-to-check claims in everything you are about to file, not only the criticals.** Subagent reports are most often wrong on counts ("17 actions"), on negatives ("no importers", "never imported", "unused") and on line numbers. One batched grep per ticket settles them, and it also yields the facts a ticket needs anyway: the callers of each function being changed, and whether the test file you are about to name exists. Before proposing a guard on a column or a rule, find every legitimate writer of it, including database functions and triggers, so the fix does not break them.
5. **Verify the fix, not only the finding.** A finding can be right while its proposed fix is wrong, and subagents are weaker on fixes than on findings. For each fix you are about to put in a ticket, read the code it changes and ask: what legitimate behaviour does this break (a deliberate second purchase, a tester's unenrolled phone, a deliberate 403)? Does it run after something destructive in the same transaction, so that failing loudly undoes the work? Does it assume something exists that does not (a button, a field in a test fixture, a provider the hook can reach)? Does a cache or shortcut outlive the permission it depended on (sign-out, deletion, revocation)? Does the claimed outcome actually follow (deduping inside one render pass does not dedupe across a separate middleware run)? In the run that added this step, most of the cross-model reviewer's corrections were of this kind.
6. Check each against the known-state file: anything listed as fixed or accepted is a likely false positive.
7. Sort: critical security, critical correctness at scale, high, then batches of warnings.

## Step 6: File in doto

doto is the only durable record, so every finding ends as a create, a fold or a drop.

**Draft, review, then file.** Write every ticket as a draft in one scratchpad file first (title, type, priority, effort, review flag, description, acceptance criteria). Then have the other model family review the whole batch in one read-only call, exactly as the `refine` skill does (`codex exec --skip-git-repo-check -p review --sandbox read-only -o <review file> - < <prompt file>` when Claude wrote the drafts). Ask it to open the cited files and report, per ticket: wrong facts, a fix that would break something, criteria that are missing or untestable, dishonest effort, a wrong review flag, a wrong severity or deadline, and a smaller change that ships the same value; and to finish with tickets that should merge. Treat it as a peer: apply what holds after you check it against the code, reject the rest with a reason. Only then create the tasks, with the corrections already in the description. Filing first and reviewing afterwards leaves the corrections as comments that contradict the description, and every ticket then has to be read in two places.

1. `find_similar_tasks` in plain language for each cluster, including done and in-review tasks. Never re-file something in review; add a comment instead.
2. **Create** one task per critical or high finding. Batch warnings by theme into tasks an agent can finish in one sitting. File decisions that only a human or the client can make as exploration tasks assigned to the human, with the questions written out, and link them as blockers of the work that depends on them.
3. Every task carries: the severity and which lens found it; `file:line` for each claim; the failure chain (who can do what, with what request, at what scale); the recommended fix naming the existing exemplar in this codebase to copy; how to verify; acceptance criteria that a test or the validation script can prove; a two-sentence plain-English summary; the tag `audit-<date>`; `createdBy: agent:claude-code`. Set `requiresHumanReview: false` only for mechanical work.
4. **File tickets that are already refined.** If the project has a definition-of-done standard for refined tasks (a refine command or a `## Refinement` section), read it before writing the first ticket and meet it at filing time: outcome-shaped criteria, the real test files named, and the project's rule on which tasks may carry a "full validation passes" criterion. Write the plain-English summary once, at filing. A ticket filed to that standard needs no separate refinement pass; a batch filed without it costs a second pass over every ticket.
5. **Fold** by commenting on the existing task. **Drop** documented placeholders and accepted conventions.
6. Fetching many tasks with full detail can exceed the tool's output limit. Fetch compact summaries, or query the saved result file for the fields you need. A single full task fetch returns its whole history and agent sessions too: use a search when only the description or status is needed.
7. Comment and link calls need each task's **full id**. Keep the full ids that searches and creates return; never complete one from its 8-character prefix. Per-task fields such as the refinement status, effort and review flag cannot be set by the bulk update, so getting them right in the create call saves one update per ticket.
8. Mark a ticket refined only if it went through the cross-model review above. Never approve one: a human gates approval.

## Step 7: Maintain the known-state file

In the same run: move resolved entries to "Fixed" with their commit or migration; add this run's open findings with their doto ids; add any newly seen production-grade pattern to the bug classes with its grep; record what was accepted and why; record the coverage gaps to close first next time; bump the last-run line with this run's counts. Reference findings by doto id, never by a report path. Run the overlay's run-recording command if there is one.

Nothing is committed. The report is not written into the repository.

## Step 8: Report

Print the report in the reply: a trend line against the previous run, findings by severity with their doto ids, known-open items now resolved, the tooling table, and a coverage section saying which lenses ran, over how many files, and what was not reached. End with a one-line verdict: `BLOCKED` on any open critical, `ACTION NEEDED` with the high count, or `HEALTHY`.

Then say what this run had to improvise. If the project has no overlay, offer to write one (a thin `.claude/commands/audit.md` that points here and lists the project facts from Step 0). If it has one, update it with anything this run proved stale.
