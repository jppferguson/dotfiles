# Task Refinement Process

This shared instruction defines the task refinement process used by both `/tskr-add` and `/tskr-refine` commands.

## Refinement Steps

When refining a task, follow these steps:

### 1. Analyze Current Task Details
- Review the existing title and description
- Identify gaps in clarity or actionability
- Note any missing context or requirements

### 2. Create Succinct Title
- Ensure the title is clear and specific
- Keep it under 80 characters
- Use action-oriented language (e.g., "Add", "Fix", "Implement", "Research")
- Include the main component/area if relevant

### 3. Enhance Description
Rewrite the description to include what an agent would need to successfully complete this task:
- **Context**: Why is this needed? What problem does it solve?
- **Current State**: What exists now (if applicable)?
- **Desired Outcome**: What should exist after completion?
- **Technical Details**: Specific technologies, files, or approaches to consider
- **Constraints**: Any limitations, dependencies, or requirements

### 4. Generate Acceptance Criteria
Create specific, measurable outcomes that define "done":
- Use checkbox format in markdown (`- [ ] Criteria item`)
- Be specific and testable
- Include both functional and non-functional requirements
- Consider edge cases and error handling
- Include testing or validation steps

### 5. Suggest Additional Context
Identify and ask for clarification on:
- Missing technical requirements
- Unclear business logic
- Ambiguous scope or boundaries
- Dependencies on other systems/tasks
- Performance or quality expectations

## Refinement Questions Template

When clarifying details, ask targeted questions such as:
- "What specific [technology/framework/approach] should be used?"
- "Are there any existing [components/patterns/conventions] I should follow?"
- "What should happen in the case of [error/edge case]?"
- "Are there any performance or accessibility requirements?"
- "How should this integrate with [existing system/component]?"

## Quality Checklist

Before presenting the refined task, ensure:
- [ ] Title is clear and action-oriented
- [ ] Description provides sufficient context for autonomous completion
- [ ] Acceptance criteria are specific and measurable
- [ ] Technical requirements are clearly stated
- [ ] Dependencies and constraints are identified
- [ ] Success metrics are defined

## Presentation Format

Present the refined task as:

```markdown
## Refined Task

**Title:** [Improved title]

**Description:**
[Enhanced description with full context]

**Acceptance Criteria:**
- [ ] [Specific, testable criterion 1]
- [ ] [Specific, testable criterion 2]
- [ ] [Specific, testable criterion 3]

**Questions for Clarification:**
- [Any unclear aspects that need user input]

Does this refined version capture what you're looking for? Any adjustments needed?
```

## User Approval

Always present the refined version for approval before proceeding with task creation or updates. Allow the user to:
- Accept the refinement as-is
- Request modifications to any section
- Provide additional context or requirements
- Skip refinement and use original version