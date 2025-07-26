# update-docs

Automatically analyze and update all documentation files in a project to keep them synchronized with the current codebase.

## What it does

1. Scan project structure to identify documentation patterns
2. Inventory available commands, scripts, and configuration
3. Update README.md files with current information
4. Refresh CLAUDE.md files with accurate project details
5. Ensure documentation consistency across the project
6. Generate summary of changes made

## Implementation

### Step 1: Project Analysis

Use LS and Glob tools to examine the project structure:

- Identify project type and organization patterns
- Find all README.md, CLAUDE.md, and other documentation files
- Locate command directories, scripts, and configuration files

### Step 2: Content Inventory

Read key files to gather current project information:

- Analyze main scripts and entry points for available commands
- Discover project-specific tools and utilities
- Check for custom commands, hooks, or extensions
- Identify configuration patterns and file structures

### Step 3: Documentation Updates

Edit documentation files with current information:

- Update README.md with accurate command references and project structure
- Refresh CLAUDE.md files with correct paths and current examples
- Sync any topic-specific or module documentation
- Ensure cross-references between documentation files are valid

### Step 4: Validation and Consistency

- Verify all file references point to existing files
- Check that examples and code snippets are current
- Maintain consistent formatting and style across all documentation
- Validate that installation and usage instructions are accurate

## Error Handling

Continue through all documentation updates even if some files have issues. Report any problems at the end with specific details about what couldn't be updated and suggested remediation steps.
