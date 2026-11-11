# Lens: architecture, structure and organisation

Read-only review aimed at making the codebase cheaper and safer to change. Each finding must be concrete enough to become a ticket: evidence with counts and paths, the cost today (a real failure or friction, not taste), a change broken into ticket-sized steps, the risk, and which existing tests verify it. Read the project's conventions file first and do not restate it; report a documented legacy area only if you can size it and propose a migration order. Do not run builds, tests or linters. Do not recommend rewrites or new frameworks, and respect any "no premature abstraction" rule: name a shared abstraction only where three or more call sites exist.

Investigate:

1. **Legacy locations and half-finished migrations.** Any pattern with two coexisting generations (two ways to gate, fetch the current user, build a form, show a table or modal, handle errors). For each: how many files on each side, what the target is, and a safe order in small steps, lowest fan-in first.
2. **Module boundaries.** Do lower layers import upward (shared library code importing from routes or UI, utilities importing from the data layer, UI importing data access)? Counts and worst offenders. Find import cycles among non-test files (write a small strongly-connected-components script in the scratchpad if needed). Is there a lint rule for boundaries or cycles, and what would adding one involve in this project's lint configuration?
3. **Oversized, mixed-responsibility files.** For the largest non-test files, open them and say which distinct responsibilities are mixed and how to split them (target file names, which exports move). Mark which splits are pure moves covered by existing tests and which are risky.
4. **Duplication.** Parallel flows and near-identical boilerplate (route preambles, scheduled-job handlers, rate-limit blocks, export handlers, document builders). Estimate duplicated lines honestly and say when a guess is a guess.
5. **Server and client split.** Share of client components; client components that could be server components with a small island; data fetched in client effects that the server already has; global client state duplicating server state.
6. **Types and validation.** How input is validated (schema library usage versus hand-parsing), where one pattern already exists to copy, hand-maintained types that duplicate generated ones.
7. **Configuration and constants.** Repeated magic numbers, environment reads scattered outside the environment schema, feature flags that are on everywhere and could be deleted (list the evidence; deletion is a product decision).
8. **Repository organisation.** Root clutter and stale artefacts (tracked or ignored, still used?), unreferenced scripts, documentation that contradicts the code or the conventions file, migration history size and the honest trade-offs of squashing it.
9. **Dependency surface.** Dependencies used in one place, two libraries for one job, overrides and patches and whether their stated "drop when" condition can be checked.
10. **Change hotspots.** From git history over the last few months, the most frequently changed non-test files cross-referenced with size: large files that change constantly are the best refactor targets. Also the ratio of tooling commits to product commits.

Group findings as HIGH VALUE (clear payoff, safe now), MEDIUM (worth a ticket, needs care), LOW / OBSERVATION. End with a coverage statement naming what was assessed only from outlines or counts rather than read.
