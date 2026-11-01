# queue-run profile: <project>

Copy to `.agents/queue/profile.md` (or `.claude/queue/profile.md`) in the project and fill in every section. queue-run substitutes these into the worker and deploy briefs.

## Repo

- REPO_PATH: absolute path of the main checkout, or a command that derives it (for example `dirname "$(git rev-parse --path-format=absolute --git-common-dir)"`) when the checkout lives in different places on different machines
- TRACKER: the task tracker (e.g. doto project <id>)
- BASE_BRANCH: the branch tasks land on (default: the repo's default branch, usually `main`). If production is a different branch, name it here too and say who moves it.

## Pickup

- PICKUP: the command or skill a worker runs to claim and implement one task, including where it creates its worktree and how it validates
- Worker model: (e.g. session default)
- Queue empty signal: what the pickup reports when nothing is eligible

## Ship

- How a worker merges to main (command/skill), and the point that counts as "pushed"
- Anything to tell workers about rebasing

## Deploy

- DEPLOY_REQUEST:
- DEPLOY_STATUS:
- DEPLOY_HISTORY:
- DEPLOY_TIMEOUT: (e.g. 40 minutes)
- Deploy worker model: (cheap)
- Code the deploy does NOT redeploy, and the manual step for each (e.g. the deployer itself, cron processes outside the app tree)

## Finalise

- FINALISE: the tracker call that moves a deployed, passed task to done, and when the tracker refuses it

## Project constraints

PROJECT_CONSTRAINTS: bullet lines appended to both briefs (known hooks and their workarounds, subagent rules, style rules).

## Live-host surfaces

Things on the host that tests must never touch; a task touching any of these gets a conditional GO:

-
