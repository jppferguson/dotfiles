---
name: init-agent-context
description: Set up the consolidated cross-agent guidance pattern in a project - create AGENT_CONTEXT.md with shared project knowledge and turn CLAUDE.md/GEMINI.md/AGENTS.md into thin agent-specific shims that reference it. Use when the user wants to initialise or consolidate agent instruction files in a repo.
disable-model-invocation: true
---

# init-agent-context

Create a shared knowledge base all AI agents reference, so project guidance lives in one file instead of being duplicated per agent.

## Step 1: Analyse the project

- Glob the repo root for existing agent files: `CLAUDE.md`, `GEMINI.md`, `AGENTS.md`, `CODEX.md`, `.cursorrules`, `.claude/`, `.ai/` directories
- Understand the project: package manager, build/test tooling, source layout, docs patterns

## Step 2: Split shared vs agent-specific content

From any existing agent files, extract:

- **Shared** (goes to AGENT_CONTEXT.md): project overview, architecture, key commands and workflows, conventions, testing guidelines, package management, security notes
- **Agent-specific** (stays in each agent's file): tool-specific instructions, custom commands, agent-only workflows

## Step 3: Create AGENT_CONTEXT.md

Structure:

```markdown
# Agent Context

This file provides shared context and guidance for all AI agents working with this project. Agent-specific instructions remain in their respective files.

## Project Overview
## Architecture & Directory Structure
## Key Commands & Workflows
## Development Conventions
## Testing Guidelines
## Package Management
## Security & Configuration
```

Fill it from the Step 1-2 analysis. Keep it factual and lean; procedures that only one agent runs belong in that agent's file or a skill.

## Step 4: Update agent files to shims

For each agent file (create CLAUDE.md and AGENTS.md at minimum; others if the user uses those tools):

```markdown
# CLAUDE.md

<!-- AGENT_CONTEXT: ./AGENT_CONTEXT.md -->

This file provides Claude-specific guidance when working with this repository.
General project context and shared guidelines are in AGENT_CONTEXT.md.

## Claude-Specific Instructions

[only genuinely Claude-specific content]
```

Remove content now covered by AGENT_CONTEXT.md; keep each agent's unique configuration.

## Step 5: Validate and summarise

- Confirm every agent file carries the `<!-- AGENT_CONTEXT: ./AGENT_CONTEXT.md -->` marker and the path resolves
- Summarise: files created, files updated, content consolidated, agent-specific content preserved

Back up before destructive edits and stop to ask if the existing structure is unexpected.
