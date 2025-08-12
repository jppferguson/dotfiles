# tskr-refine

Refine an existing task to improve clarity, completeness, and actionability for autonomous completion.

## Usage

/tskr-refine [--id TASK_ID] [--next]

## What it does

- Step 1: Load project configuration and identify target task
- Step 2: Read current task details
- Step 3: Apply task refinement process
- Step 4: Update task with refined content
- Step 5: Confirm changes and provide summary

## Step 1: Load Configuration and Identify Task

First, read the project configuration using the Read tool:

```bash
# Check for config files (prefer .local over standard)
CONFIG_FILE=""
if [ -f .tskrrc.local ]; then
    CONFIG_FILE=".tskrrc.local"
elif [ -f .tskrrc ]; then
    CONFIG_FILE=".tskrrc"
else
    echo "ERROR: No .tskrrc file found. Run /tskr-init first."
    exit 1
fi
echo "Using $CONFIG_FILE"
```

Read the configuration file to understand:
- `task_format`: "files" or "single_file"
- `task_dir`: Directory or file name for task storage

If no configuration is found, stop and instruct the user to run `/tskr-init` first.

### Task Selection

If `--id TASK_ID` is provided:
- Use the specified task ID
- Validate that the task exists

If `--next` flag is provided:
- Find the next pending task (highest priority, oldest creation date)
- Use that task for refinement

If no flag is provided:
- List available pending tasks
- Prompt user to select which task to refine
- Show format: `ID - Title (Type, Priority)`

## Step 2: Read Current Task Details

### For files format
- Read the task file: `{task_dir}/{ID}-{title}.md`
- Parse the existing content to extract:
  - Current title
  - Task type and priority
  - Current description
  - Existing acceptance criteria
  - Additional notes

### For single_file format
- Read the tasks file
- Find the task entry by ID
- Parse the existing content

## Step 3: Apply Task Refinement Process

**IMPORTANT**: Use the shared refinement instructions from `/instructions/task-refinement.md`.

Follow the complete refinement process:
1. Analyze current task details
2. Create succinct title
3. Enhance description for agent completion
4. Generate specific acceptance criteria
5. Ask clarifying questions if needed

Present the refined version to the user for approval using the format specified in the task refinement instructions.

## Step 4: Update Task with Refined Content

Once the user approves the refinement:

### For files format
Update the task file with the refined content:

```markdown
# {Refined Title}

**Type:** {task_type}  
**Priority:** {priority}  
**Status:** pending  
**Created:** {original_date}  
**Refined:** {current_date}  
**ID:** {task_id}

## Summary

{refined_title}

## Description

{enhanced_description}

## Acceptance Criteria

{refined_acceptance_criteria}

## Notes

{additional_notes}

---

_Created by tskr-add on {original_timestamp}_  
_Refined by tskr-refine on {refinement_timestamp}_
```

### For single_file format
Update the task entry in the tasks file:

```markdown
### {ID} - {Refined Title}

**Type:** {task_type} | **Priority:** {priority} | **Created:** {original_date} | **Refined:** {current_date}

{enhanced_description}

**Acceptance Criteria:**
{refined_acceptance_criteria}

**Notes:** {additional_notes}

---
```

## Step 5: Validation and Summary

Perform validation:
- Verify task file was updated successfully
- Check that formatting is correct
- Ensure all refined fields are present

Provide confirmation:
- ✅ **Task Refined**: #{task_id} - {refined_title}
- 📋 **Type**: {task_type} | **Priority**: {priority}
- 📍 **Location**: {file_path_or_section}
- 🔄 **Next**: Use `/tskr-next` to process this refined task

## Error Handling

- **No config found**: Direct user to run `/tskr-init`
- **Task not found**: List available tasks and prompt for selection
- **Invalid task ID**: Show valid task IDs and re-prompt
- **File read/write errors**: Report permissions or disk space issues
- **User cancellation**: Exit without making changes

## Command Line Options

- `--id TASK_ID`: Refine specific task by ID
- `--next`: Refine the next pending task automatically

## Examples

```bash
# Interactive task selection
/tskr-refine

# Refine specific task
/tskr-refine --id 003

# Refine next pending task
/tskr-refine --next
```

## Integration Notes

This command works seamlessly with:
- `/tskr-add --minimal`: Create quick tasks, refine them later
- `/tskr-next`: Process refined tasks with better context
- Both file-based and single-file task storage formats