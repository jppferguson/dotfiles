# Global Agent Instructions

Instructions for all AI coding agents (Claude Code, Codex, Gemini, OpenCode, etc.) working with Jamie Ferguson. Loaded globally via symlinks from each agent's config directory (see ~/.agentrc/README.md).

## About

- Freelance web developer on macOS. Projects live in `~/Development` (client work under `Clients/`, personal under `Github/` or `Personal/`).
- Use British English in all prose, comments, commit messages and docs (organise, colour, analyse).

## Default stack

- Next.js + React + TypeScript + Tailwind CSS
- Supabase (Postgres, RLS, migrations) and Sentry on client projects
- Sanity CMS and Storybook on some projects; WordPress/PHP/ACF on legacy client sites
- Package manager varies per project: check the lockfile before running anything (yarn on most client work, pnpm on newer projects). Never mix.
- Node versions managed via asdf

## Task management

Tasks live in doto (personal OS, exposed via the doto MCP server). When a project is wired to a doto project, use the next-task skill (`~/.agentrc/skills/next-task/`) to work tickets end to end.

## Working rules

Commits:

- Never commit unprompted, and never commit mid-fix or with failing checks.
- When I approve ("commit that", "yes"), commit immediately without asking again.
- Commit messages: specific and imperative. No emojis. Explain the why for non-obvious changes.

Dev servers:

- Check whether a dev server is already running (usually port 3000 or 3001) before starting one.

Verification:

- After a fix, verify it yourself (run the test, check the output, tail the logs) before telling me it works. For visual/CSS changes, confirm the rendered result rather than assuming.
- If the project has a validation script (`yarn validate`, lint, tests), run it before presenting work as done.

Scope:

- Do not rename components, variables or files unless asked. No drive-by refactors.
- Implement fully or not at all: no TODOs, stubs or placeholder code.

Style essentials (full details in `~/.agentrc/standards/`):

- No em dashes, no emojis, no filler comments; comment only the non-obvious "why".
- Specific names over generic ones (no `data`, `result`, `temp`).
- No premature abstraction; no defensive checks for impossible cases.

## Standards reference

Read the relevant file before substantial work of that kind (do not preload them all):

- `~/.agentrc/standards/code-style.md` - code formatting and naming preferences
- `~/.agentrc/standards/markdown-style.md` - markdown authoring rules
- `~/.agentrc/standards/anti-ai-patterns.md` - full list of banned AI-generated patterns
- `~/.agentrc/standards/best-practices.md` - development philosophy
- `~/.agentrc/standards/tech-stack.md` - default technology choices
