# fix-code

Runs a comprehensive code quality pipeline: TypeScript compilation → ESLint fixes → Jest tests → ESLint warning cleanup.

## Usage

/fix-code

## What it does

- Step 1: Run TypeScript compiler to check for type errors
- Step 2: Run ESLint with --fix to auto-fix errors
- Step 3: Run Jest to ensure tests pass
- Step 4: Fix any remaining ESLint warnings
- Operates on src/ and test/ directories
- Stops execution if any step encounters errors

You are helping the user run a comprehensive code quality and testing pipeline. Follow these steps carefully:

## Step 1: Environment Validation

First, check if the required tools are available using the Bash tool:

```bash
which tsc || echo "TypeScript compiler not found"
which eslint || echo "ESLint not found"
which jest || echo "Jest not found"
```

If any critical tools are missing, provide installation instructions:

- For TypeScript: `npm install -g typescript` or `npm install --save-dev typescript`
- For ESLint: `npm install --save-dev eslint`
- For Jest: `npm install --save-dev jest`

If tools are missing, stop execution and ask the user to install them first.

## Step 2: Directory Validation

Use the LS tool to verify target directories exist and contain relevant files:

- Check if `src/` directory exists and contains TypeScript/JavaScript files
- Check if `test/` directory exists and contains test files
- If neither directory exists, check current directory for relevant files

## Step 3: Execute Code Quality Pipeline

### 3.1: TypeScript Compilation Check

Run TypeScript compiler to check for type errors:

```bash
tsc --noEmit
```

**Error Handling**: If this command fails (exit code != 0), STOP execution immediately and report the TypeScript errors. Do not proceed to the next steps until these are resolved.

Show summary: "✓ TypeScript compilation passed" or "✗ TypeScript errors found"

### 3.2: ESLint Auto-Fix (Errors Only)

Run ESLint with auto-fix to resolve fixable errors:

```bash
eslint src/ test/ --fix --quiet
```

**Error Handling**: If this command fails, STOP execution and report the ESLint errors that couldn't be auto-fixed. Do not proceed until these are manually resolved.

Show summary of what was fixed: "✓ ESLint auto-fixes applied" or "✗ ESLint errors require manual fixing"

### 3.3: Jest Test Suite

Run Jest to ensure all tests pass:

```bash
jest
```

**Error Handling**: If tests fail, STOP execution and report which tests failed. Do not proceed to warning cleanup until all tests pass.

Show summary: "✓ All tests passed" or "✗ Test failures detected"

### 3.4: ESLint Warning Cleanup

Run ESLint again to fix any remaining warnings (not just errors):

```bash
eslint src/ test/ --fix
```

**Error Handling**: This step should continue even if warnings remain, but report what couldn't be auto-fixed.

Show summary of warnings addressed: "✓ ESLint warnings cleaned up" or "! Some ESLint warnings require manual attention"

## Step 4: Final Summary

Provide a comprehensive summary including:

- ✅ **TypeScript**: No type errors found
- ✅ **ESLint Errors**: All errors fixed automatically
- ✅ **Tests**: All Jest tests passing
- ⚠️ **ESLint Warnings**: X warnings fixed, Y warnings remain
- 📊 **Files Modified**: List any files that were automatically modified
- ⏱️ **Total Time**: Execution duration
- 🚀 **Status**: Ready for commit / Needs manual fixes

## Error Handling Notes

This command uses "stop on first error" strategy:

- If TypeScript compilation fails, execution stops immediately
- If ESLint finds unfixable errors, execution stops
- If Jest tests fail, execution stops
- Only ESLint warnings in the final step are allowed to continue

This ensures your code is in a deployable state before proceeding to the next step.
