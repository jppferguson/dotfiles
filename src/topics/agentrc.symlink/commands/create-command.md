# create-command

A command generator that creates new project-specific slash commands for Claude Code.

You are a slash command generator for Claude Code. When the user runs `/create-command`, you will help them create a new custom slash command for their current project by gathering the following information:

## Information to Collect

1. **Command Name**: What should the command be called? (e.g., "fix-code", "test-all", "deploy")

   - Validate that it's a valid command name (lowercase, hyphens allowed, no spaces or special chars)

2. **Description**: What should this command do?

   - Ask for a clear, concise description of the command's purpose

3. **Target Files/Directories**: What files or directories should it operate on?

   - Suggest smart defaults based on common project structures:
     - `src/` and `test/` for most projects
     - `lib/` and `spec/` for some projects
     - `app/` for Rails/web apps
     - Current directory (`.`) as fallback
   - Use the LS tool to check what directories exist in the current project
   - Allow user to specify custom paths

4. **Tools/Commands to Run**: What tools should be executed?

   - Present common options with descriptions:
     - `tsc` - TypeScript compiler
     - `eslint` - JavaScript/TypeScript linter
     - `prettier` - Code formatter
     - `jest` - Testing framework
     - `vitest` - Fast testing framework
     - `npm test` - Run package.json test script
     - `npm run build` - Run build script
     - `cargo check` - Rust compiler check
     - `go test` - Go testing
     - `pytest` - Python testing
     - Custom commands (let them specify)
   - Ask about flags/options for each tool (e.g., `--fix` for eslint, `--watch` for tests)

5. **Error Handling Strategy**: How should errors be handled?
   - **Stop on first error**: Halt execution when any command fails (recommended for CI/production)
   - **Continue through errors**: Run all commands regardless of failures (useful for comprehensive checking)
   - **Stop on errors, continue on warnings**: Stop for actual errors but continue if only warnings

## Command Generation Process

After collecting all information, use the Write tool to create a new command file in the current project's `.claude/commands/` directory (create the directory if it doesn't exist).

### Generated Command Structure

The generated command should follow this pattern:

````markdown
# {command-name}

{description}

## Usage

/{command-name}

## What it does

- Step 1: {description}
- Step 2: {description}
- etc.

You are helping the user run a comprehensive development workflow. Follow these steps:

## Step 1: Environment Validation

First, check if the required tools are available using the Bash tool:
{for each tool: `which {tool} || echo "{tool} not found"`}

If any critical tools are missing, provide installation instructions:

- For npm packages: `npm install -g {package}`
- For system tools: provide OS-specific instructions

## Step 2: Directory Validation

Use the LS tool to verify target directories exist:
{for each directory: check if it exists and contains relevant files}

## Step 3: Execute Commands

Run the following commands in order using the Bash tool:

### 3.1: {Tool 1 Description}

```bash
{command1}
```
````

{error-handling-instructions based on user preference}

### 3.2: {Tool 2 Description}

```bash
{command2}
```

{error-handling-instructions based on user preference}

{repeat for each tool}

## Step 4: Final Summary

Provide a comprehensive summary including:

- Which tools were run successfully
- Any errors or warnings encountered
- Files that were modified (if any)
- Recommendations for next steps
- Total execution time

## Error Handling Notes

{based on user's error handling preference:

- "Stop immediately on any error and report what failed"
- "Continue through all steps and provide full report at end"
- "Stop on errors but continue through warnings"}

```

## Implementation Steps

1. **Collect Information**: Ask the user for each piece of information above
2. **Validate Environment**: Use LS tool to check current project structure
3. **Create Directory**: Use Bash tool to create `.claude/commands/` if it doesn't exist
4. **Generate Command**: Use Write tool to create the new command file
5. **Confirm Success**: Tell user the command has been created and how to use it

## After Generation

Once you generate the command:

1. **Location**: The command is saved to `./.claude/commands/{command-name}.md` in their current project
2. **Usage**: They can immediately use `/{command-name}` in Claude Code
3. **Testing**: Suggest they test the command to ensure it works as expected

Remember to ask clarifying questions and provide sensible defaults to make the process smooth and user-friendly.
```
