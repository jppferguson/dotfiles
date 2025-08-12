# Markdown Style Guide

> Version: 1.0.0
> Last Updated: 2025-01-15

## Context

This file is part of the Agentrc standards system. These global markdown formatting rules are referenced by all projects and provide default documentation standards. Individual projects may extend or override these rules in their `.agentrc/product/markdown-style.md` file.

## General Principles

### Consistency First
- Maintain consistent formatting throughout all markdown files
- Use the same patterns for similar content structures
- Apply standards uniformly across documentation

### Readability Focus
- Optimise for human readability in both rendered and source formats
- Use clear, descriptive headings and structure
- Ensure proper spacing and visual hierarchy

### British English Standards
- Use British spellings: colour, behaviour, realise, centre, organisation
- Apply British punctuation conventions consistently
- Maintain professional tone and clarity

## Heading Standards

### Heading Style (ATX Format)
- **Always use ATX headings:** `# Heading` not `Heading\n=======`
- **No trailing spaces:** `# Title` not `# Title   `
- **Single space after hash:** `# Title` not `#Title` or `#  Title`
- **No unnecessary punctuation:** `# Overview` not `# Overview.`

### Heading Hierarchy
- **Start with H1:** Every document should have exactly one `# Title`
- **Sequential levels:** Don't skip levels (H1 → H2 → H3, never H1 → H3)
- **Descriptive headings:** Use clear, action-oriented language
- **Consistent capitalisation:** Use title case for main headings

### Examples
```markdown
# Document Title

## Main Section

### Subsection

#### Detail Level

## Another Main Section
```

## List Formatting

### Unordered Lists
- **Use hyphens:** `- Item` (preferred over `*` or `+`)
- **2-space indentation:** For nested lists
- **Blank lines:** Around list blocks, not between simple items
- **Consistent punctuation:** Either all items have full stops or none do

```markdown
Here's a list of features:

- First feature item
- Second feature item
  - Nested sub-item
  - Another sub-item
- Third feature item

This text follows the list.
```

### Ordered Lists
- **Use `1.` notation:** Let markdown handle numbering
- **2-space indentation:** For nested lists
- **Consistent throughout:** Don't mix `1.` `2.` with `1)` `2)`

```markdown
Follow these steps:

1. First step with detailed explanation
2. Second step
   1. Sub-step one
   2. Sub-step two
3. Final step
```

## Code Formatting

### Inline Code
- **Use backticks:** `` `code` `` for inline code references
- **Clear context:** Make it obvious what represents code vs text
- **No unnecessary backticks:** Don't wrap regular words

### Code Blocks
- **Always specify language:** ``` ```javascript ``` not just ``` ``` ```
- **Proper indentation:** Maintain code formatting within blocks
- **Descriptive examples:** Include comments or context when helpful

```markdown
Install the package:

```bash
npm install package-name
```

Then import it in your JavaScript:

```javascript
import { feature } from 'package-name';
```
```

### Language Identifiers
- `bash` for shell commands
- `javascript` or `js` for JavaScript
- `typescript` or `ts` for TypeScript  
- `json` for JSON data
- `yaml` for YAML files
- `markdown` or `md` for markdown examples

## Link Formatting

### Inline Links
- **Use for short URLs:** `[Link text](https://example.com)`
- **Descriptive text:** Avoid "click here" or "read more"
- **Clear purpose:** Link text should indicate destination/purpose

### Reference Links
- **Use for long URLs:** Keep source readable
- **Group at bottom:** Place reference definitions at document end
- **Descriptive IDs:** Use meaningful reference identifiers

```markdown
Check the [official documentation][docs] for more details.

You can also review the [contribution guidelines][contrib].

[docs]: https://example.com/very/long/documentation/url
[contrib]: https://example.com/another/very/long/url/for/contributing
```

## Table Formatting

### Structure Standards
- **Consistent alignment:** Align columns for source readability
- **Header separation:** Use proper header separator row
- **No trailing pipes:** End rows cleanly

```markdown
| Feature | Status | Priority |
|---------|--------|----------|
| Authentication | Complete | High |
| User profiles | In progress | Medium |
| Admin panel | Planned | Low |
```

### Content Guidelines
- **Keep cells concise:** Use brief, clear content
- **Consistent capitalisation:** Match heading style throughout
- **Proper spacing:** Single spaces around pipe characters

## Spacing and Line Breaks

### Paragraph Spacing
- **Single blank line:** Between paragraphs
- **No trailing spaces:** End lines cleanly
- **Consistent line endings:** Use LF (Unix style)

### Section Spacing
- **Two blank lines:** Before major headings (H1, H2)
- **One blank line:** Before minor headings (H3, H4)
- **One blank line:** Around code blocks, lists, and tables

```markdown
# Major Heading

Content paragraph here.

## Another Major Section  

More content follows.

### Subsection

Details about the subsection.
```

## Special Elements

### Front Matter (YAML)
```markdown
---
title: Document Title
description: Brief document description
date: 2025-01-15
tags: [markdown, standards, documentation]
---
```

### Horizontal Rules
- **Use three hyphens:** `---`
- **Blank lines around:** Ensure proper separation
- **Sparingly:** Only when clear section break needed

### Emphasis and Strong Text
- **Italic:** Use `*italic*` for emphasis
- **Bold:** Use `**bold**` for strong emphasis  
- **Code:** Use `` `code` `` for technical terms

### Blockquotes
- **Use `>` notation:** For quoted content
- **Proper attribution:** When quoting sources
- **Consistent formatting:** Maintain style throughout

```markdown
> This is a blockquote that provides
> important context or quoted material.
>
> — Author Name
```

## File Organisation

### File Naming
- **Lowercase with hyphens:** `user-guide.md` not `User_Guide.md`
- **Descriptive names:** Clear purpose from filename
- **Consistent patterns:** Follow project conventions

### Directory Structure
- **Logical grouping:** Related documents together
- **Clear hierarchy:** Nested folders when appropriate
- **Index files:** Use `README.md` for directory overviews

## Quality Checklist

Before finalising any markdown document:

- [ ] Single H1 heading at top
- [ ] Sequential heading hierarchy (no skipped levels)
- [ ] All code blocks have language specified
- [ ] No trailing whitespace on any lines
- [ ] Consistent list formatting (2-space indents)
- [ ] Tables properly aligned and formatted
- [ ] Links are working and descriptive
- [ ] British English spelling throughout
- [ ] Proper spacing around sections
- [ ] Front matter formatted correctly (if present)

---

_These standards apply to all markdown files created by humans and AI agents. Customise project-specific overrides in `.agentrc/product/markdown-style.md` when needed._