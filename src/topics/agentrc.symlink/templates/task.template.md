# {TASK_TITLE}

**Type:** {TASK_TYPE}  
**Priority:** {PRIORITY}  
**Status:** pending  
**Created:** {CREATED_DATE}  
**ID:** {TASK_ID}

## Summary

{BRIEF_SUMMARY_OF_TASK}

## Description

{DETAILED_DESCRIPTION_OF_WHAT_NEEDS_TO_BE_DONE}

Provide enough detail that an LLM can understand and complete this task autonomously without additional instructions. Include:

- Current state/behavior (for bugs)
- Expected outcome/behavior
- Relevant file paths or components
- Any constraints or requirements
- Dependencies or prerequisites

## Acceptance Criteria

{CHECKLIST_OF_REQUIREMENTS_FOR_COMPLETION}

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Progress Checklist

- [ ] Understand requirements and acceptance criteria
- [ ] Plan implementation approach
- [ ] Implement core functionality
- [ ] Add tests (if applicable)
- [ ] Update documentation
- [ ] Verify all acceptance criteria met
- [ ] Mark task as complete

## Notes

{ADDITIONAL_CONTEXT_CONSTRAINTS_OR_RELATED_INFORMATION}

- Related issues/tasks
- Technical debt considerations
- Performance requirements
- Security considerations
- Testing requirements

---

_Template for task creation - replace placeholders with actual content_

## Field Descriptions

### Required Fields

- **TASK_TITLE**: Clear, concise title (under 100 characters)
- **TASK_TYPE**: One of: bug, feature, task, question
- **PRIORITY**: One of: high, medium, low
- **TASK_ID**: Sequential number with leading zeros (001, 002, etc.)
- **CREATED_DATE**: ISO date format (YYYY-MM-DD)

### Content Sections

- **Summary**: One-sentence description of the task
- **Description**: Detailed explanation with sufficient context for autonomous completion
- **Acceptance Criteria**: Measurable requirements that define "done"
- **Notes**: Optional additional context, constraints, or related information

### Status Values

- **pending**: Ready to be picked up by an agent
- **in_progress**: Currently being worked on (includes agent assignment)
- **completed**: Finished and archived

### Progress Tracking (added automatically by tskr-next)

When a task is picked up, these fields are added:

- **Started**: Timestamp when work began  
- **Last Updated**: Timestamp of most recent progress
- **Completed**: Timestamp when work finished (for completed tasks)

Progress is tracked via the Progress Checklist - agents check off items as they complete them, allowing tasks to be resumed if interrupted.
