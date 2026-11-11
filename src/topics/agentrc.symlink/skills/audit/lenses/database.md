# Lens: database, grants and row-level security

Read-only review. Prefer the **live local catalogue** over reading every migration: it is the end state. Read individual migrations only to explain a live finding or to check the newest ones in detail. Local database only; never staging or production; never reset or migrate. If the project has its own catalogue audit script, run it and report its result. First check whether the local database is behind the repository's migrations, and say so.

Check, for every application table and for file storage:

1. Row-level security disabled, or enabled with zero policies on a table granted to ordinary roles.
2. Permissive `USING (true)` / `WITH CHECK (true)` policies (permissive policies are OR-ed together).
3. Policies applying to the anonymous role that call a helper it cannot execute.
4. Missing tenant scoping on staff branches; a global-scope helper used where a tenant-scoped one is needed.
5. **Own-row update policies with a table-level grant**: list the columns no trigger or check constraint guards, and for each ask what trusts it (role, tenant, email, verified flags, counters, timestamps). Prove it with an update inside a transaction you roll back.
6. Privilege-elevating functions (security definer): missing pinned `search_path`, missing authorisation in the body, execute granted more widely than intended, duplicate overloads left behind by a changed signature. Read the bodies of the ones ordinary users can execute; say how many you did not read.
7. Views that bypass the caller's row-level security.
8. Helper functions used in policies that are not stable, or are called per row where a sub-select would be evaluated once.
9. Table grants: anonymous grants with no reason to exist, legacy grants wider than the app uses (truncate, trigger, references), default privileges for new tables and functions.
10. File storage: public flags versus content sensitivity, per-bucket object policies (own-folder checks, tenant scoping), size and exact content-type limits.
11. **Delete rules**: foreign keys whose delete action contradicts what the code or comments assume (for example "cascades" where the constraint blocks). These decide whether a person or tenant can actually be erased.
12. Privacy: tables holding personal data with a read path wider than the owner or tenant; log and queue tables that keep personal data with no pruning.
13. Missing indexes on foreign keys used in policies or hot filters (top offenders only, as warnings).

Report findings as CRITICAL / HIGH / WARNING, each with the table or function, the migration that created it if located, the failure chain (who can do what), a concrete fix, and the SQL you ran to verify it. End with a coverage statement: what was checked live, which migrations were read, and what was not reached.
