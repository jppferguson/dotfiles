# Lens: performance and correctness at scale

Read-only review. Use the production scale figures in the project context (row counts, response caps, function time limits); a finding must say the scale at which it bites. Grep each pattern across the whole scope, then read each hit's surrounding code before reporting it. Do not flag missing memoisation if the framework's compiler handles it.

Check:

1. **Reads silently capped or unbounded**: list, export and cron queries with no range, limit or paging; API response row caps that return a short result with a success status; a returned-row count used as a total.
2. **Lists of ids passed in a URL or query** that grow with a table.
3. **One-row-per-child reads folded into a set** that decides a destructive action.
4. **N+1**: awaits inside loops over query results (pages, actions, crons, email sending, document generation, exports).
5. **Serial independent awaits** on hot pages and layouts.
6. **Queues and crons**: per-run bounds, time budget against the function limit, slow external calls inside a loop, no ordering, a failed item that stays at the head forever, producers that outrun the consumer. Do the arithmetic.
7. **Heavy handlers**: document and archive generation, exports. Whole file buffered versus streamed, concurrency, time limit, behaviour at hundreds of rows or images.
8. **Caching**: shared caches keyed without the user or tenant (report as CRITICAL: it is a privacy bug), stale data after a write, layout-wide invalidation on frequent writes.
9. **Round trips before first render**: middleware, the root layout, the current-user helper (is it cached per request?), client providers that refetch what the server already has.
10. **Client bundle**: large client-only dependencies imported statically into shared layouts or widely used components; code splits defeated by a static import next to a dynamic one; whole pages as client components.
11. **Media**: unoptimised images, signed-URL generation in loops.
12. **Database** (needs a shell and the local database; say so if you lack one): filters or sorts on columns with no index, per-row subqueries in functions, `select *` on wide tables in list views.

Report findings as CRITICAL (data silently wrong or lost at production scale, or a caching privacy bug) / HIGH (will time out or fail at realistic scale) / WARNING (measurable waste), each with `file:line`, the failure chain with the scale at which it bites, a fix naming the existing exemplar in this codebase to copy, and "verified by reading" or "unverified". Report clean areas in one line each. End with a coverage statement: which patterns were grepped repo-wide, how many hits were read, and what was not reached.
