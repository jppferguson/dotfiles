# tskr-next

Pick up and complete the next available task in the sequence, or work on a specific task by ID. Includes agent assignment to prevent conflicts and automatic completion workflows.

## Usage

/tskr-next [task_id] [--show-only] [--release task_id]

## What it does

- Step 1: Load configuration and find next available task
- Step 2: Assign agent ID to prevent conflicts
- Step 3: Display task details and begin work
- Step 4: Complete task and handle post-completion workflow

You are helping the user process tasks from their task management system. Follow these steps carefully:

## Step 1: Load Configuration and Parse Options

First, read the project configuration:

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

Parse command line options:

- `task_id`: Specific task to work on (overrides sequential order)
- `--show-only`: Display task without assigning or starting work
- `--release task_id`: Release an assigned task back to pending state

If `--release` is provided, skip to Step 6 (Release Task).

## Step 2: Find Next Available Task

### For files format:

1. Use LS tool to list all files in the task directory
2. Read each task file to check status
3. Filter for tasks with status "pending" (not "in_progress" or "completed")
4. Sort by priority (high→medium→low) then by ID (oldest first)
5. Select first available task, or specific task if ID provided

### For single_file format:

1. Read the tasks file
2. Parse all task entries
3. Find tasks in the "Pending" section
4. Sort by priority and creation date
5. Select next task or specific task by ID

If no task_id is specified, pick the first available task in priority order.
If task_id is specified, verify it exists and is available.

### Handle No Available Tasks:

If no pending tasks found:

```markdown
📋 **No Pending Tasks**

All tasks are either completed or in progress.

- Use `/tskr-add` to create new tasks
- Check for stuck in_progress tasks that may need to be released
```

## Step 3: Check Agent Assignment

Before assigning the task, check if it's already assigned to another agent:

### Check for existing assignment:

- Look for "Assigned To:" field with agent ID and timestamp
- Check if assignment is within the timeout period (from .tskrrc `agent_timeout`)
- If assignment is expired, automatically release it

### Generate Agent ID:

Create unique agent identifier:

```bash
AGENT_ID="claude-$(date +%s)"
```

## Step 4: Assign Task and Display

If `--show-only` is provided, display task without assignment and stop here.

Otherwise, assign the task and display details:

### Update task with agent assignment

#### For files format

Add or update these fields in the task file:

```markdown
**Status:** in_progress
**Assigned To:** {agent_id}
**Started:** {current_timestamp}
```

#### For single_file format

Move task from "Pending" to "In Progress" section and update:

```markdown
## In Progress

### {ID} - {Task Title} [ASSIGNED: {agent_id}]

**Type:** {task_type} | **Priority:** {priority} | **Started:** {current_timestamp}
```

### Display task details

```markdown
🎯 **Picked up Task #{task_id}**

# {Task Title}

**Type:** {task_type} | **Priority:** {priority}  
**Agent:** {agent_id}
**Started:** {current_timestamp}

## Description

{task_description}

## Acceptance Criteria

{acceptance_criteria}

## Notes

{additional_notes}

---

**Ready to work on this task. When complete, I'll handle the completion workflow.**
```

## Step 5: Work on Task

Begin working on the task according to its requirements:

1. **Read and understand** all task details thoroughly
2. **Plan the approach** based on task type:

   - **bug**: Investigate, reproduce, fix, test
   - **feature**: Design, implement, test
   - **task**: Follow specific instructions
   - **question**: Research, analyse, document findings

3. **Execute the work** using appropriate tools
4. **Validate completion** against acceptance criteria
5. **Run validation script** if configured in .tskrrc

## Step 6: Task Completion Workflow

Once the task work is complete:

### Run Validation (if configured)

```bash
# If validation_script is set in .tskrrc
{validation_script}
```

If validation fails, stop and report what needs to be fixed before marking complete.

### Update Task Status

#### For files format

Update the task file:

```markdown
**Status:** completed
**Completed:** {current_timestamp}  
**Completed By:** {agent_id}
```

Move file to completed subdirectory or rename with prefix:

```bash
mkdir -p {task_dir}/completed
mv {task_dir}/{task_file} {task_dir}/completed/
```

#### For single_file format

Move task from "In Progress" to "Completed" section:

```markdown
## Completed

### {ID} - {Task Title} ✅

**Type:** {task_type} | **Completed:** {current_timestamp}
{summary_of_work_done}
```

### Generate Commit Message

Use the `commit_template` from .tskrrc, substituting placeholders:

- `{task_title}`: Task title
- `{task_type}`: bug/feature/task/question
- `{task_id}`: Task ID number

Example: "fix: resolve login validation bug (#003)"

### Completion Summary

```markdown
✅ **Task #{task_id} Completed**

**Summary:** {brief_summary_of_work}
**Duration:** {time_taken}
**Validation:** {passed/failed/skipped}

**Suggested Commit Message:**
{generated_commit_message}

**Next Steps:**

- Review the changes made
- Commit with suggested message if satisfied
- Run `/tskr-next` to continue with next task
```

## Step 7: Release Task (--release option)

If `--release task_id` is provided:

1. Find the specified task
2. Remove agent assignment
3. Reset status to "pending"
4. Move back to pending section (for single_file format)
5. Update timestamps

## Error Handling

- **No config found**: Direct user to run `/tskr-init`
- **Task not found**: List available tasks with IDs
- **Task already assigned**: Show assigned agent and timeout info
- **Validation script fails**: Keep task in_progress, show failures
- **Invalid task ID**: Provide valid ID range
- **Permission errors**: Report file/directory permission issues

## Command Options

- `task_id`: Work on specific task (e.g., `/tskr-next 005`)
- `--show-only`: Display task details without starting work
- `--release task_id`: Release stuck task back to pending state

## Examples

```bash
# Work on next available task
/tskr-next

# Work on specific task
/tskr-next 003

# View task without starting
/tskr-next 003 --show-only

# Release stuck task
/tskr-next --release 003
```

## Agent Conflict Prevention

The system prevents multiple agents from working on the same task:

- Each task assignment includes unique agent ID
- Assignments expire after `agent_timeout` seconds (default: 1 hour)
- Expired assignments are automatically released
- Use `--release` to manually free stuck tasks
