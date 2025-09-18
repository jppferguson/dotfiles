# Repository Guidelines

<!-- AGENT_CONTEXT: ./AGENT_CONTEXT.md -->

This guide outlines Codex-specific practices for collaborating on the dotfiles repository. Shared project guidance lives in [AGENT_CONTEXT.md](./AGENT_CONTEXT.md); review and update that file whenever you introduce repo-wide changes.

## Shared Context

- Treat `AGENT_CONTEXT.md` as the canonical source for structure, commands, style, and testing expectations.
- If you add general guidance, update the shared context first and then reference it here—never duplicate content that other agents will need.
- Keep the marker `<!-- AGENT_CONTEXT: ./AGENT_CONTEXT.md -->` intact so tooling can locate the shared file; mirror this pattern in other agent docs.

## Codex Workflow

- Use `rg`/`fd` for discovery and always set the `workdir` parameter on shell commands; avoid `cd` unless absolutely necessary.
- Default to ASCII output and add comments only where they unblock future readers.
- Follow the testing policy in the shared context; when you skip a command (e.g., due to sandbox limits) call out the gap in the final message.
- Summarise command output instead of dumping it verbatim unless explicitly requested.

## Collaboration Notes

- Resolve instruction precedence as: repository docs → system/developer guidance → user request.
- Stop immediately if you notice unexpected filesystem changes you did not make and surface the issue in your response.
- Offer natural next steps—tests, commits, manual verification—once work is complete, and note any verification you could not run.

## Updating Shared Guidance

- Propose shared-context edits in your response before altering the file and link to the section you intend to change.
- After modifying `AGENT_CONTEXT.md`, confirm that every agent document still references the correct relative path.
- Log structural changes (new sections, renamed anchors) so this pattern can be rolled out consistently to other repositories.
