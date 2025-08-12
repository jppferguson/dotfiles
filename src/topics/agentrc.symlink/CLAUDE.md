# CLAUDE.md

> Agentrc User Standards
> Last Updated: 2025-09-15

## Purpose

This file directs Claude Code to use your personal Agentrc standards for all development work. These global standards define your preferred way of building software across all projects.

## Global Standards

### Development Standards

- **Tech Stack Defaults:** @~/.agentrc/standards/tech-stack.md
- **Code Style Preferences:** @~/.agentrc/standards/code-style.md
- **Markdown Formatting:** @~/.agentrc/standards/markdown-style.md
- **Best Practices Philosophy:** @~/.agentrc/standards/best-practices.md

### Agentrc Instructions

- **Initialize Products:** @~/.agentrc/instructions/plan-product.md
- **Plan Features:** @~/.agentrc/instructions/create-spec.md
- **Execute Tasks:** @~/.agentrc/instructions/execute-tasks.md
- **Analyse Existing Code:** @~/.agentrc/instructions/analyse-product.md

## How These Work Together

1. **Standards** define your universal preferences that apply to all projects
2. **Instructions** guide the agent through Agentrc workflows
3. **Project-specific files** (if present) override these global defaults

## Using Agentrc Commands

You can invoke Agentrc commands directly:

- `/plan-product` - Start a new product
- `/create-spec` - Plan a new feature
- `/execute-task` - Build and ship code
- `/analyse-product` - Add Agentrc to existing code

## Important Notes

- These are YOUR standards - customize them to match your preferences
- Project-specific standards in `.agentrc/product/` override these globals
- Update these files as you discover new patterns and preferences

---

_Using Agentrc for structured AI-assisted development. Learn more at [buildermethods.com/agentrc](https://buildermethods.com/agentrc)_
