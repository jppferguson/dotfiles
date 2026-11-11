# Lens: test estate

Read-only review of where a real regression could ship despite a green run, and where test effort is wasted. Do NOT run any test runner, type checker, linter or build. Read the test configuration, the CI workflows, and existing artefacts only (last coverage summary, last end-to-end report, mutation report, any run-history files); state each artefact's date. Never print a large report file; aggregate it with a query tool.

Investigate:

1. **What the thresholds do not cover.** Read the coverage include and exclude patterns: what is excluded entirely (route handlers, server actions, pages), so that the global number says nothing about it? Are thresholds enforced in CI at all, or only locally? Are there per-directory thresholds on security-critical code? How much headroom sits between thresholds and actual?
2. **Untested security-critical surface.** Action, route and service files with no sibling test; data-access and auth modules with no test; database tables with no row-level-security test naming them; privilege-elevating database functions no test calls. Rank by risk, and correct for files covered by differently named tests.
3. **Gate tests.** Sample server-action tests and answer one question for each: would deleting the permission-check line turn a test red? Count how many mock the auth module wholesale, and whether they still assert the gate call and the rejected path. Is there any static or meta-test that every public action calls a gate?
4. **Meta-tests that keep classes of bug out.** Does anything fail when a new table ships without row-level security, when a function's execute grant widens, when a new route is missing from the access matrix, when a new public endpoint is added without review? These catalogue-driven tests are usually cheaper than per-case tests.
5. **Webhooks and payments.** Bad signature, missing secret, replay, and tampered-body cases; real recorded provider fixtures versus hand-built objects; whether signature verification itself is mocked away.
6. **End-to-end suite.** Last run's pass, fail, flaky and skipped counts; which specs retried; fixed sleeps; user journeys with no spec (compare against the route tree); coverage of the viewports and browsers real users have; accessibility checks.
7. **Regressions that recently escaped.** Read a few months of fix commits: which kinds of bug recur, and is there any automated detector for that kind? Propose the cheapest detector that would have caught them.
8. **Mutation testing.** What the last report actually covered and how stale it is; a cadence of scoped runs worth their time.
9. **Speed and flakiness**, only where an artefact supports a number. Say when the data does not support a recommendation.
10. **Missing kinds of test**, stated plainly as exists or does not: provider contract tests, migration replay from a production-like snapshot, seed validity, load tests for scheduled jobs at production scale, per-route security-header pins, post-deploy smoke tests.

Group findings as HIGH VALUE (a realistic regression would ship green today), MEDIUM, LOW / OBSERVATION, each with evidence, the regression it would let through, a change in ticket-sized steps naming the existing test or helper to copy, an effort size, and how success is measured (ideally: "reverting commit X makes it fail"). Then a short "do not bother" list of attractive ideas the evidence says are not worth it here. End with a coverage statement naming what could not be determined without running tests.
