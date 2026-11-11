# Lens: data layer and server-side actions

Read-only review of server actions, mutation route handlers, services, webhooks, crons and the shared data-access modules in scope. Start with bulk greps (which gate each exported function calls, and whether it precedes the first query), then read the outliers. If the project lists its publicly callable actions (an allowlist or build manifest), read it first: it is the attack surface.

Check every exported action and mutating handler for:

1. **A session-derived gate before the first read or write**, and before any privileged (service-role, admin) client is created.
2. **Identity taken from arguments or form data** (user id, tenant id, approver id, email, payment or record ids). Is each id re-bound to the gated tenant or user in the query itself, or could a member of tenant A pass an id belonging to tenant B? Trace every action that takes an id and uses a privileged client. This is the most important check.
3. **Functions that assume a gate they cannot see**: exported helpers that run privileged queries on caller-supplied ids and are only safe because of who calls them today. Modules where every export is a public endpoint by directive.
4. **The permissions engine**: role hierarchy mistakes, missing-actor and missing-target handling (must fail closed), blank or undefined scope treated as "unscoped", self-action edge cases (delete self, demote the last owner), one privileged role acting on a more privileged one through a side path such as an email edit.
5. **Lookups by a mutable attribute** (email, code, name) where the looked-up person can change that attribute themselves. Invite and hand-over flows when the email already belongs to someone.
6. **Read-check, then write, then a second write with no transaction**: balances, credits, enrolment, payment state. What is left behind when the second step fails or two requests race?
7. **Input validation**: schema-validated input, bounded string lengths and array sizes, file uploads (declared versus stored type, size, path traversal, user-controlled file names in storage keys or response headers), CSV formula injection in exports, URL scheme checks on stored links.
8. **User text into rendered output**: Markdown or HTML email bodies, PDF text, admin screens. Anonymous input reaching portal-branded email is the classic.
9. **Webhooks**: signature verified over the raw body before any side effect, constant-time comparison, replay and idempotency, the secret-unset case, and whether a transient failure returns success to the provider (so it never retries).
10. **Crons and queues**: secret check, a claim or lease so overlapping runs do not double-process, ordering, an attempts counter and a failed state so a poison row leaves the queue, time budget against the function limit, partial scans used as a complete set.
11. **Public unauthenticated actions**: rate limiting and whether it fails open, enumeration (does the response distinguish "exists"?), what an anonymous caller can write and how much, whether any anonymous response returns personal data that the caller did not supply.
12. **Payments**: amount and currency derived on the server, idempotency keys, test or simulator paths unreachable in production.
13. **Secrets and randomness**: tokens and codes from a non-cryptographic generator, secret comparison that is not constant-time, secrets or whole third-party payloads in logs and error messages.
14. **Failure handling**: swallowed errors that return an empty list, zero or success, which the caller then treats as truth.
15. **Project conventions** named in its conventions file (cache revalidation rules, query-building rules, required module headers).

Report findings as CRITICAL / HIGH / WARNING, each with `file:line`, a one-line description, the failure chain (which role, what request, what result), a concrete fix naming the project helper or exemplar to copy, and "verified by reading" or "unverified". Report clean areas in one line each. End with a coverage statement: files read in full, files classified by grep only, and files not reached.
