# tskr-reorder

Review, reprioritize, and reorder pending tasks to set the optimal execution sequence for your workflow.

## Usage

/tskr-reorder [--priority-only] [--interactive]

## What it does

- Step 1: Load project configuration and current task list
- Step 2: Display current task order with priorities
- Step 3: Allow bulk priority changes and manual reordering
- Step 4: Update task storage with new order and priorities
- Step 5: Confirm changes and show final order

## Step 1: Load Configuration and Tasks

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

Load all pending tasks and their current details.

## Step 2: Display Current Task Order

Show the current task list in a clear, reviewable format:

```
Current Task Order:
==================

1. [HIGH] 001 - Fix login validation bug (bug)
   Description: User authentication fails with special characters...
   
2. [MEDIUM] 003 - Add dark mode toggle (feature)  
   Description: Implement theme switching functionality...
   
3. [MEDIUM] 002 - Update documentation (task)
   Description: Refresh API docs with latest changes...
   
4. [LOW] 004 - Research new framework (question)
   Description: Investigate React vs Vue for next project...
```

## Step 3: Reordering Options

### Priority-Only Mode (`--priority-only`)

Allow bulk priority changes without manual reordering:

1. **Bulk Priority Changes**:
   - Prompt: "Change priority for multiple tasks? (e.g., '1,3:high' or '2,4:low')"
   - Support format: `task_numbers:new_priority`
   - Examples: 
     - `1,3:high` - Set tasks 1 and 3 to high priority
     - `2:low,4:medium` - Set task 2 to low, task 4 to medium

2. **Individual Priority Changes**:
   - Show each task and prompt: "Keep priority [CURRENT] or change to (h/m/l/skip)?"
   - Allow quick priority adjustments

After priority changes, auto-sort by:
1. Priority level (high → medium → low)
2. Creation date (oldest first within same priority)

### Interactive Mode (`--interactive` or default)

Full reordering capabilities:

1. **Priority Changes**: Same as priority-only mode
2. **Manual Reordering**: 
   - Show numbered list
   - Prompt: "Enter new order (comma-separated numbers) or 'skip' to keep current:"
   - Example: `3,1,4,2` reorders tasks to: task 3 first, task 1 second, etc.
   - Validate that all task numbers are included

3. **Drag-and-Drop Style Prompts**:
   - "Move task X up/down? (u/d/skip)"
   - "Insert task X before which task? (1-N)"

## Step 4: Update Task Storage

### For files format

Rename task files to reflect new order:
1. Create temporary backup of current files
2. Rename files with new sequential numbering:
   - `001-new-first-task.md`
   - `002-new-second-task.md` 
   - etc.
3. Update any internal cross-references if needed
4. Update priority metadata in task files

### For single_file format

Reorder task entries in the file:
1. Read current tasks file
2. Reorder the pending tasks section according to new sequence
3. Update priority metadata for changed tasks
4. Preserve task IDs but change display order
5. Update timestamps for modified tasks

## Step 5: Validation and Summary

Perform validation:
- Verify all tasks are accounted for
- Check that file operations completed successfully
- Ensure priority changes are reflected
- Validate sequential numbering (files format)

Provide comprehensive summary:

```
✅ Task Reordering Complete
=========================

Priority Changes:
- Task 003: medium → high
- Task 002: medium → low

New Execution Order:
1. [HIGH] 001 - Fix login validation bug
2. [HIGH] 003 - Add dark mode toggle  
3. [LOW] 002 - Update documentation
4. [LOW] 004 - Research new framework

📋 Total tasks reordered: 4
🔄 Next: Use `/tskr-next` to start with the first task
```

## Command Line Options

- `--priority-only`: Only change priorities, auto-sort by priority + date
- `--interactive`: Full reordering capabilities (default)
- `--preview`: Show what order would be without making changes

## Advanced Features

### Batch Operations

Support batch commands in interactive mode:
- `priorities 1,3:high 2:low` - Set multiple priorities at once
- `order 3,1,4,2` - Set complete new order
- `move 2 before 1` - Insert task 2 before task 1
- `swap 1 3` - Swap positions of tasks 1 and 3

### Smart Suggestions

Analyze task dependencies and suggest optimal order:
- Look for mentions of other task IDs in descriptions
- Identify prerequisite relationships
- Suggest logical groupings (all bugs together, related features)
- Flag potential dependency conflicts

## Error Handling

- **No config found**: Direct user to run `/tskr-init`
- **No pending tasks**: Inform user and suggest `/tskr-add`
- **Invalid task numbers**: Show valid range and re-prompt
- **File operation errors**: Rollback changes and report issues
- **Incomplete reordering**: Ensure all tasks are accounted for

## Examples

```bash
# Full interactive reordering
/tskr-reorder

# Quick priority review only
/tskr-reorder --priority-only

# Preview changes without applying
/tskr-reorder --preview

# Quick batch priority changes
/tskr-reorder --priority-only
# Then: "1,3:high 2,4:low"
```

## Integration Notes

Works with:
- All task storage formats (files and single_file)
- Tasks created by `/tskr-add`
- Tasks refined by `/tskr-refine`
- Maintains compatibility with `/tskr-next` execution order

## Workflow Tips

1. **Regular Review**: Use `/tskr-reorder --priority-only` for quick priority sweeps
2. **Project Phases**: Reorder tasks when entering new development phases
3. **Dependency Management**: Manually order tasks to respect dependencies
4. **Focus Sessions**: Move related tasks together for better focus