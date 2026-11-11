# Lens: authorisation surface (pages, layouts, route handlers)

Read-only review of every page, layout and route handler in scope. Classify all files by which gate they call with bulk greps first, then read the ones that are ungated, unusual, reachable by the least-privileged role with an id in the URL, or new.

Check:

1. **A gate before any data read** on every page. Tenant scoping taken from the route parameter, never from the query string or from fetched data. Admin-only surfaces that admit a weaker admin role than their siblings do.
2. **Id-in-URL pages** reachable by ordinary users (`[uid]`, `[id]` and similar): an ownership assertion, and the fetched entity's tenant checked against the route's tenant. A page that renders an empty shell when the row is hidden instead of a not-found.
3. **Feature-flagged surfaces**: the role or capability gate runs before the feature check, so enablement does not leak through a 404 versus a redirect, and every surface under a gated root is gated.
4. **Route handlers**: exports (CSV, PDF, ZIP), cron routes (how the secret is compared, constant-time, fails closed when the variable is unset), webhooks (signature over the raw body before any side effect, behaviour with the secret unset), development and debug routes (exactly what stops them in production), API routes (auth, tenant scope, input bounds).
5. **Routes excluded from the middleware or proxy matcher** must authenticate themselves. A check on `Origin`, `Referer` or any header a non-browser client can set is not authentication.
6. **Public pages**: what user-controlled input reaches a query, a redirect target or rendered output; whether ids and codes are guessable and what a correct guess reveals.
7. **Redirect targets and "next" parameters**: pinned to the same origin.
8. **State changes on GET** (logout, toggles) and attacker-supplied text rendered on trusted pages (`?message=`, `?error=`).
9. **Prefix-matched public paths** that a future route name could fall into by accident.
10. **The project's access matrix or spec**, if one exists: any page whose code gate disagrees with it.
11. **Privacy**: pages showing another person's data to a role that should not see it; personal data in page titles or URLs.

Report findings as CRITICAL / HIGH / WARNING, each with `file:line`, a one-line description, the failure chain (which role, which URL, what they see or do), a concrete fix naming the project helper to use, and "verified by reading" or "unverified". Report clean areas in one line each. End with a coverage statement: counts by gate type, how many files were read versus classified by grep, and an explicit list of files not reached.
