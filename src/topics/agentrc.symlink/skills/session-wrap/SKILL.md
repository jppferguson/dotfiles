---
name: session-wrap
description: End-of-session housekeeping - summarise what was done, review and update memory, suggest skill/agent improvements, and flag stale artifacts. Use when the user says "wrap up", "session wrap" or is ending a working session.
disable-model-invocation: true
---

# Session Wrap

End-of-session housekeeping. Work through these steps:

## Step 1: Summarise the session

Briefly list what was accomplished (features built, bugs fixed, tests added, refactoring done). Bullet points, not paragraphs.

## Step 2: Review and update memory

Read the memory files in the project's auto-memory directory:

1. Read `MEMORY.md` and any topic files it links to
2. Identify new patterns, conventions or gotchas from this session worth remembering
3. Check whether existing memories are now outdated or wrong
4. Update, create or remove memory files as needed:
   - Do NOT save session-specific context (current task, in-progress state)
   - Do NOT duplicate what is already in CLAUDE.md or CLAUDE.local.md

Present what changed and why.

## Step 3: Review skills and agents

Check what exists at global and project level:

1. Global skills: `~/.agentrc/skills/`
2. Global agents: `~/.claude/agents/`
3. Project skills/commands: `.claude/skills/` and `.claude/commands/` in the current project

Then consider whether the session's work suggests new skills (repeatable convention-heavy workflows), new agents (recurring deep-analysis tasks), updates to existing ones, or removals. For each suggestion give: name, why it helps, global vs project, and whether to create now or note for later.

Be conservative: only suggest things that would genuinely save time across multiple sessions.

## Step 4: Check for stale artifacts

Look for cleanup candidates: completed plans in `.claude/plans/`, stale task lists, docs (test plans, specs) needing final status, completed TODOs in project docs. Report findings but ask before destructive changes.
