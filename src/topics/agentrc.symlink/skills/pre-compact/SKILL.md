---
name: pre-compact
description: Check whether now is a safe moment to compact the conversation, and if it is, save the session's key working state to the scratchpad so nothing important depends on the compaction summary. Use when the user says "pre-compact", "can I compact", "ok to compact" or is about to run /compact.
disable-model-invocation: true
---

# Pre-compact

Decide whether the session can be compacted now. If it can, write a state file that lets you carry on from it alone after compaction.

## Step 1: Check for reasons to wait

Go through each check against the live state, not your memory of it. Run the commands; don't assume.

- **Mid-operation git state:** a rebase, merge, cherry-pick or squash-merge in progress, or staged but uncommitted work in a shared checkout (`git status` in the main checkout and any worktree you touched). Another agent can stash or swallow staged changes while you are compacting.
- **Half-applied change:** a multi-file edit you have started but not finished, where the remaining edits live only in your head.
- **A foreground command whose output you still need to act on:** a build, test run or deploy you started in the foreground and have not read yet. Background tasks that will notify you are fine, as long as Step 2 records them.
- **An unanswered question to the user:** you asked something and have not had the answer. Compaction can lose the framing of the question.
- **Uncommitted reasoning:** a root cause or decision you reached but have not written anywhere (ticket, commit message, notes). Write it down first, then continue.
- **Coordination in flight (only if you are supervising agents):** a worker holds a lock you granted (for example a ship mutex), a blocking question from a worker is unanswered, or a delivery has been read but not acknowledged. Holding a granted lock across compaction is fine if Step 2 records it; an unanswered blocking question is not, so answer it first.

## Step 2: Give a verdict

- **WAIT** if any check failed and it can't be resolved in a few seconds. Name each blocker, what you are waiting for, and roughly how long. Don't write the state file yet; offer to run this skill again once the blocker clears.
- **OK** otherwise. Resolve any quick blockers (answer the question, finish the edit, write down the reasoning), then go to Step 3.

## Step 3: Save the state file

Write `<scratchpad>/compact-state.md`, using the session's scratchpad directory from the system prompt. If a state file for this work already exists in the scratchpad (for example `coordinator-state.md`), update that one instead of creating a second.

Include only what you could not cheaply rediscover from the repo, git log or the task tracker:

- **Goal:** what the user asked for, in their words where it matters, including constraints they set (worker counts, models, "don't commit", deadlines).
- **How the work runs:** the loop or procedure you are following, with exact commands, helper script paths and any message templates. Enough that you could continue it cold.
- **Current state:** what is in flight right now. Background task IDs, worker or dispatch IDs, locks held and by whom, queued requests, the last acknowledged message or delivery ID.
- **Results so far:** per item, its outcome and identifier (task ID, commit SHA, PR), plus anything left for the user to verify.
- **Decisions and corrections:** choices the user made and course corrections they gave this session, so you don't re-ask or regress.
- **Incidents and gotchas:** anything that went wrong, its cause, and the workaround currently in force.
- **Next steps:** the next two or three concrete actions.

Use plain bullets. Write IDs, SHAs and paths in full; summaries lose them first.

## Step 4: Hand back

Tell the user:

1. The verdict and, if OK, the absolute path of the state file.
2. A ready-to-paste command that points the post-compaction session at the file, for example: `/compact Read <absolute path> first and continue from it.`

Keep the reply to a few lines. The detail belongs in the file.
