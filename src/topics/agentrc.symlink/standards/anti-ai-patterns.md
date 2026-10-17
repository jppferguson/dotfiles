# Anti-AI Pattern Standards

> Version: 1.0.0
> Last Updated: 2025-11-23
> Scope: Rules to prevent obviously AI-generated code patterns

## Context

This file is part of the Agentrc standards system. These rules specifically target common patterns that appear in AI-generated code but are undesirable in production codebases. These standards apply globally across all projects.

## Forbidden Patterns

### Typography and Formatting

**Never use em dashes (—)**

- Use hyphens (-) or restructure sentences instead
- Em dashes are a telltale sign of AI-generated content
- Examples:
  - ❌ "This function — which calculates totals — is critical"
  - ✅ "This function calculates totals and is critical"
  - ✅ "This function (which calculates totals) is critical"

**Never use emojis**

- Do not add emojis to code, comments, or commit messages
- Exception: Only when explicitly requested by the user
- Examples:
  - ❌ "// Calculate total 🧮"
  - ❌ "git commit -m 'Fix bug 🐛'"
  - ✅ "// Calculate total"
  - ✅ "git commit -m 'Fix authentication timeout bug'"

### Comments and Documentation

**Never add unnecessary comments above code**

- Do not comment code that is self-explanatory
- Only comment the "why" behind non-obvious decisions
- Never comment what the code does if it's clear from reading it
- Examples:
  - ❌ `// Create a new user`
    `const user = new User()`
  - ❌ `// Loop through all items`
    `items.forEach(item => ...)`
  - ✅ `// Use batch processing to avoid rate limits`
    `processBatch(items, BATCH_SIZE)`

**Never over-explain obvious code**

- Avoid verbose documentation for simple, self-evident functions
- Don't add docstrings that just restate the function name
- Examples:
  - ❌ `/** Gets the user's name. Returns the name of the user. */`
    `function getUserName() { ... }`
  - ✅ `function getUserName() { ... }` (no comment needed)

**Avoid conversational language in code**

- Never use "Let's", "We'll", "Now we", etc. in comments
- Write declarative statements instead
- Examples:
  - ❌ "// Let's calculate the total"
  - ❌ "// Now we'll validate the input"
  - ✅ "// Calculate total with tax"
  - ✅ "// Validate input format"

**Avoid qualifying language**

- Never use "simply", "just", "easily", "obviously" in comments or docs
- These words are filler and often condescending
- Examples:
  - ❌ "// Simply add the numbers together"
  - ❌ "// Just call the API endpoint"
  - ✅ "// Sum all values in the array"
  - ✅ "// Call /api/users endpoint"

### Variable and Function Naming

**Never use generic placeholder names**

- Avoid: `data`, `result`, `response`, `temp`, `value`, `item` (unless truly generic)
- Use specific, descriptive names that indicate purpose
- Examples:
  - ❌ `const data = await fetch(url)`
  - ❌ `const result = calculate(x, y)`
  - ✅ `const userProfile = await fetch(url)`
  - ✅ `const monthlyTotal = calculate(x, y)`

**Never create single-use "helper" functions**

- Don't abstract code that's only used once
- Don't create utilities for one-time operations
- Inline the logic instead
- Exception: Complex algorithms that benefit from naming

### Code Completeness

**Never add TODO or placeholder comments**

- Either implement the feature completely or don't add it
- Never leave "TODO: implement this" comments
- Never use placeholder text like "your code here"
- Examples:
  - ❌ `// TODO: Add error handling`
  - ❌ `// Implementation goes here`
  - ❌ `throw new Error('Not implemented yet')`
  - ✅ Implement error handling completely or leave it out

**Never add incomplete implementations**

- Don't scaffold code with the intention of "filling it in later"
- Don't create empty functions or classes
- Either build it completely or don't create it

### Code Organization

**Never add backwards-compatibility hacks**

- Don't rename unused variables with underscore prefix (`_unused`)
- Don't re-export types for backwards compatibility
- Don't add `// removed` comments for deleted code
- If something is unused, delete it completely
- Examples:
  - ❌ `function foo(x, _unusedParam) { ... }`
  - ❌ `// This function was removed - use newFunction instead`
  - ✅ Delete the unused code entirely

**Never over-engineer solutions**

- Don't add configuration options for hypothetical future needs
- Don't create abstractions for code that appears only once or twice
- Three similar lines of code is better than a premature abstraction
- Examples:
  - ❌ Creating a configurable utility for a one-off calculation
  - ❌ Building a plugin system when you only have one use case
  - ✅ Implement exactly what's needed, nothing more

### Git Commits

**Never write generic commit messages**

- Avoid vague messages like "update files", "fix bug", "changes"
- Be specific about what changed and why
- Examples:
  - ❌ "Update components"
  - ❌ "Fix bug"
  - ❌ "Make changes"
  - ✅ "Add loading state to user profile component"
  - ✅ "Fix race condition in authentication flow"

### Error Handling

**Don't add defensive checks for impossible scenarios**

- Trust internal code and framework guarantees
- Only validate at system boundaries (user input, external APIs)
- Don't add error handling for scenarios that can't happen
- Examples:
  - ❌ Null checks for framework-guaranteed values
  - ❌ Try-catch for synchronous operations that can't throw
  - ✅ Validate user input at API endpoints
  - ✅ Handle network failures for external API calls

### Language and Tone

**Avoid overly formal or academic language**

- Write clear, direct comments in plain language
- Don't use unnecessarily complex words
- Examples:
  - ❌ "Utilize the aforementioned methodology"
  - ❌ "This functionality facilitates the optimization of..."
  - ✅ "Use the method described above"
  - ✅ "This function optimizes..."

## General Principles

1. **Write like a human developer** - Code should look like it was written by an experienced engineer, not generated
2. **Trust the code** - If code is self-documenting, don't document it further
3. **Be specific** - Use precise names and descriptions, never generic placeholders
4. **Be complete** - Implement features fully or don't add them at all
5. **Be direct** - No conversational language, qualifiers, or filler words
6. **Be minimal** - Only add what's necessary, nothing more

---

*These rules help ensure AI-generated code is indistinguishable from human-written code. Update this file as new AI patterns emerge.*
