# tskr-add

Add a new task, bug, feature, or question to the task management system with interactive prompts to ensure sufficient detail for autonomous completion.

## Usage

/tskr-add [--minimal] [--refine] [--title "Task title"] [--type TYPE] [--priority PRIORITY]

## What it does

- Step 1: Load project configuration from .tskrrc
- Step 2: Gather task details through interactive prompts
- Step 3: Generate unique task ID and create task entry
- Step 4: Add task to storage in the configured format

You are helping the user add a new task to their task management system. Follow these steps carefully:

## Step 1: Load Configuration

First, read the project configuration using the Read tool:

```bash
# Check for config files in order of preference
if [ -f .tskrrc.local ]; then
    echo "Using .tskrrc.local"
elif [ -f .tskrrc ]; then
    echo "Using .tskrrc"
else
    echo "ERROR: No .tskrrc file found. Run /tskr-init first."
    exit 1
fi
```

Read the configuration file to understand:

- `task_format`: "files" or "single_file"
- `task_dir`: Directory or file name for task storage
- Current task numbering scheme

If no configuration is found, stop and instruct the user to run `/tskr-init` first.

## Step 2: Check for Minimal Mode

If `--minimal` flag is provided, skip interactive prompts and use provided title:

- Create task with minimal required fields
- Use "task" as default type, "medium" as default priority
- Prompt only for description if title not provided

## Step 3: Interactive Task Creation

Gather the following information through prompts:

### Task Title (Required)

- Prompt: "What is the task title/summary?"
- Validate: Non-empty, under 100 characters
- Example: "Fix login validation bug" or "Add dark mode toggle"

### Task Type (Required)

Present options:

- **bug**: Something broken that needs fixing
- **feature**: New functionality to implement
- **task**: General work item or improvement
- **question**: Investigation or research needed

Default: "task"

### Priority Level (Required)

Present options:

- **high**: Urgent, blocking other work
- **medium**: Important, should be done soon
- **low**: Nice to have, can wait

Default: "medium"

### Detailed Description (Required)

- Prompt: "Provide a detailed description of what needs to be done:"
- Validate: At least 20 characters
- Suggest including context, current behavior, expected behavior

### Task Refinement Mode

After gathering basic details, ask: "Would you like me to refine this task for better clarity and completeness? (y/n)"

If yes, apply the task refinement process:

**IMPORTANT**: Use the shared refinement instructions from `/instructions/task-refinement.md`.

Follow the complete refinement process defined in the shared instructions:
1. Analyze current task details
2. Create succinct title  
3. Enhance description for agent completion
4. Generate specific acceptance criteria
5. Ask clarifying questions if needed
6. Present refined version for approval

The user can also skip refinement during creation and use `/tskr-refine` later to enhance the task.

### Acceptance Criteria (Optional but Recommended)

- Prompt: "List the acceptance criteria (what defines 'done'):"
- Allow multiple criteria
- Format as checkboxes in markdown
- Skip if empty
- If task refinement was performed, these may be auto-generated

### Additional Notes (Optional)

- Prompt: "Any additional notes, context, or constraints?"
- Allow empty
- Include relevant file paths, related issues, etc.

## Step 4: Generate Task ID

Determine the next available task ID:

### For files format

1. Use LS tool to list existing task files in the task directory
2. Parse filenames to find highest existing ID number
3. Increment by 1, format with leading zeros (001, 002, etc.)

### For single_file format

1. Read the tasks file
2. Parse existing task headers to find highest ID
3. Increment by 1

## Step 5: Create Task Entry

### For files format

Create new file `{task_dir}/{ID}-{sanitized-title}.md`:

```markdown
# {Task Title}

**Type:** {task_type}  
**Priority:** {priority}  
**Status:** pending  
**Created:** {current_date}  
**ID:** {task_id}

## Summary

{title}

## Description

{detailed_description}

## Acceptance Criteria

{acceptance_criteria_as_checkboxes}

## Notes

{additional_notes}

---

_Created by tskr-add on {timestamp}_
```

### For single_file format

Add to the "Pending" section of the tasks file:

```markdown
### {ID} - {Task Title}

**Type:** {task_type} | **Priority:** {priority} | **Created:** {current_date}

{detailed_description}

**Acceptance Criteria:**
{acceptance_criteria_as_checkboxes}

**Notes:** {additional_notes}

---
```

## Step 6: Sort and Organize Tasks

Ensure tasks are ordered for sequential processing:

### Priority-based ordering

1. High priority tasks first
2. Medium priority tasks second
3. Low priority tasks last
4. Within same priority, order by creation date (oldest first)

### For files format

- Rename files if needed to maintain sequential numbering
- Update any cross-references

### For single_file format

- Reorder entries within the Pending section
- Maintain ID numbers but adjust display order

## Step 7: Validation

Perform basic validation:

- Verify task file was created successfully
- Check that task ID is unique
- Ensure formatting is correct
- Validate that required fields are present

## Step 8: Success Summary

Provide confirmation of task creation:

- ✅ **Task Created**: #{task_id} - {title}
- 📋 **Type**: {task_type} | **Priority**: {priority}
- 📍 **Location**: {file_path_or_section}
- 🔄 **Next**: Use `/tskr-next` to process this task or add more with `/tskr-add`

## Error Handling

- **No config found**: Direct user to run `/tskr-init`
- **Invalid task directory**: Check permissions and create if needed
- **Duplicate task ID**: Regenerate ID and retry
- **File write errors**: Report permissions or disk space issues
- **Missing required fields**: Re-prompt for required information

## Command Line Options

- `--minimal`: Skip interactive prompts, create basic task
- `--refine`: Automatically enable task refinement mode
- `--title "Title"`: Pre-populate task title
- `--type bug|feature|task|question`: Pre-set task type
- `--priority high|medium|low`: Pre-set priority level

## Examples

```bash
# Interactive mode (recommended)
/tskr-add

# Quick task creation
/tskr-add --minimal --title "Update documentation"

# Task with automatic refinement
/tskr-add --refine --title "Improve user dashboard"

# Pre-filled bug report
/tskr-add --type bug --priority high --title "Login form crashes on submit"

# Quick task that can be refined later
/tskr-add --minimal --title "Research new API integration"
```
