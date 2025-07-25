# tskr-init

Initialize a task management system in the current project for handling small tasks and bugs autonomously with Claude Code.

## Usage

/tskr-init

## What it does

- Step 1: Check for existing configuration files (.tskrrc, .tskrrc.local)
- Step 2: Create configuration file with user preferences
- Step 3: Create task storage (directory or single file)
- Step 4: Add example task to demonstrate the system

You are helping the user initialize a task management system for autonomous task handling. Follow these steps carefully:

## Step 1: Check for Existing Configuration

First, check if configuration files already exist using the Read tool:

```bash
# Check for existing config files
ls -la .tskrrc .tskrrc.local 2>/dev/null || echo "No existing config found"
```

If configuration files exist, read them with the Read tool and ask the user if they want to:

- Keep existing configuration
- Update/merge with new settings
- Start fresh (backup existing)

## Step 2: Gather Configuration Preferences

Ask the user for these configuration options:

### Task Storage Format

- **files**: Individual files in a tasks/ directory (recommended for complex tasks)
- **single_file**: All tasks in a single tasks.md file (simpler for small projects)

Default: "files"

### Task Directory/File Name

- Directory name if using files format (default: "tasks")
- File name if using single file format (default: "tasks.md")

### Validation Script (Optional)

- Command to run after task completion for validation
- Common examples: "npm test", "cargo check", "python -m pytest"
- Leave empty for no validation

### Commit Message Template

- Template for suggested commit messages
- Use {task_title}, {task_type}, {task_id} as placeholders
- Default: "{task_type}: {task_title}"

### Agent Timeout

- How long (in seconds) an agent can hold a task before it's released
- Default: 3600 (1 hour)

## Step 3: Create Configuration File

Use the Write tool to create `.tskrrc` with the collected preferences:

```yaml
# Task Management Configuration
task_format: "files" # or "single_file"
task_dir: "tasks" # directory name or file name
validation_script: "" # optional command to run after completion
commit_template: "{task_type}: {task_title}"
agent_timeout: 3600 # seconds before agent assignment expires
```

There is also an example with full config and comments here: @~/.agentrc/templates/.tskrrc.template

## Step 4: Create Task Storage

Based on the task_format setting:

### If task_format is "files":

1. Use the Bash tool to create the tasks directory:

```bash
mkdir -p {task_dir}
```

2. Create a README.md in the tasks directory explaining the system:

```markdown
# Tasks

This directory contains individual task files managed by the tskr system.

- Tasks are processed sequentially by ID
- Each task file contains all necessary details for autonomous completion
- Use `tskr-add` to create new tasks
- Use `tskr-next` to process the next available task

## Task States

- **pending**: Ready to be picked up
- **in_progress**: Currently being worked on by an agent
- **completed**: Finished and archived
```

### If task_format is "single_file":

Create the tasks file with header:

```markdown
# Tasks

## Pending

_No pending tasks_

## In Progress

_No tasks in progress_

## Completed

_No completed tasks_
```

## Step 5: Create Example Task

Add a sample task to demonstrate the system:

### For files format:

Create `{task_dir}/001-example-task.md`:

```markdown
# Example Task

**Type:** task  
**Priority:** low  
**Status:** pending  
**Created:** {current_date}  
**ID:** 001

## Summary

This is an example task to demonstrate the tskr system.

## Description

Review the task management system implementation and verify all commands work correctly.

## Acceptance Criteria

- [ ] tskr-init creates proper configuration
- [ ] tskr-add can create new tasks
- [ ] tskr-next can process tasks sequentially
- [ ] Configuration is respected across commands

## Notes

Delete this example task once you've verified the system works.
```

### For single_file format:

Add to the Pending section of tasks.md:

```markdown
## Pending

### 001 - Example Task

**Type:** task | **Priority:** low | **Created:** {current_date}

Review the task management system implementation and verify all commands work correctly.

**Acceptance Criteria:**

- [ ] tskr-init creates proper configuration
- [ ] tskr-add can create new tasks
- [ ] tskr-next can process tasks sequentially
- [ ] Configuration is respected across commands

**Notes:** Delete this example task once you've verified the system works.
```

## Step 6: Final Summary

Provide a summary of what was created:

- ✅ **Configuration**: .tskrrc created with user preferences
- ✅ **Storage**: Task storage created ({files/single_file} format)
- ✅ **Example**: Sample task added for testing
- 📋 **Next Steps**:
  - Use `/tskr-add` to create your first real task
  - Use `/tskr-next` to process tasks
  - Customize .tskrrc as needed

## Configuration Reference

The .tskrrc file supports these options:

- `task_format`: "files" or "single_file"
- `task_dir`: Directory/file name for task storage
- `validation_script`: Optional command for post-completion validation
- `commit_template`: Template for commit messages (supports {task_title}, {task_type}, {task_id})
- `agent_timeout`: Seconds before releasing assigned tasks (default: 3600)

You can also create a `.tskrrc.local` file for machine-specific overrides.
