# add-note

Add a timestamped note to the project's NOTES.md file for quick observations, reminders, or insights.

## Usage

/add-note [--category CATEGORY] [note text]

## What it does

- Step 1: Check for existing NOTES.md file in current directory
- Step 2: Create NOTES.md if it doesn't exist with proper structure
- Step 3: Add timestamped note entry to the file
- Step 4: Optionally categorize the note for better organization

## Step 1: Check for Existing NOTES.md

Use the Read tool to check if `NOTES.md` exists in the current working directory.

If the file doesn't exist, proceed to Step 2 to create it.
If it exists, read the current content to understand the structure.

## Step 2: Create NOTES.md (if needed)

If NOTES.md doesn't exist, create it with this initial structure:

```markdown
# Project Notes

Quick notes, observations, and reminders for this project.

---

## Recent Notes

```

## Step 3: Gather Note Content

### If note text provided as argument:
- Use the provided text directly
- Skip interactive prompts

### If no note text provided:
- Prompt: "Enter your note:"
- Allow multi-line input (press Enter twice to finish)
- Validate: At least 5 characters required

## Step 4: Add Note Entry

Append the new note to the NOTES.md file using this format:

```markdown
### {timestamp} {category_badge}

{note_content}

---

```

### Timestamp Format
Use ISO date with time: `2024-01-15 14:30`

### Category Badges (optional)
If `--category` is specified, add a badge:
- `🐛 BUG` - For bug observations
- `💡 IDEA` - For feature ideas or improvements  
- `🔧 TECH` - For technical notes or decisions
- `📝 TODO` - For things to remember to do
- `❓ QUESTION` - For questions or uncertainties
- `📊 DATA` - For data observations or metrics
- `🎯 GOAL` - For objectives or targets
- `⚠️ ISSUE` - For problems or concerns
- `✅ DONE` - For completed items or achievements
- `📚 LEARNING` - For insights or lessons learned

If no category specified, omit the badge.

### Note Positioning
- Add new notes at the top of the "Recent Notes" section
- Keep existing notes below in chronological order
- Maintain the `---` separator between entries

## Step 5: Confirmation

Provide brief confirmation:
- ✅ **Note added** to NOTES.md
- 📝 **Content**: First 50 characters of note...
- 🕐 **Time**: {timestamp}

## Command Line Options

- `--category CATEGORY`: Add category badge (bug, idea, tech, todo, question, data, goal, issue, done, learning)
- `--private`: Add note with private marker (useful for personal observations)

## Examples

```bash
# Interactive note entry
/add-note

# Quick note with text
/add-note "Remember to update the API documentation after this feature"

# Categorized note
/add-note --category idea "Could we use caching here to improve performance?"

# Bug observation
/add-note --category bug "Login form doesn't validate email format properly"

# Technical decision
/add-note --category tech "Decided to use Redis for session storage instead of memory"
```

## File Structure Example

After several notes, NOTES.md will look like:

```markdown
# Project Notes

Quick notes, observations, and reminders for this project.

---

## Recent Notes

### 2024-01-15 14:30 💡 IDEA

Could we use caching here to improve performance? The API calls are pretty slow.

---

### 2024-01-15 12:15 🐛 BUG

Login form doesn't validate email format properly. Users can submit invalid emails.

---

### 2024-01-15 09:45

Remember to update the API documentation after this feature is complete.

---

```

## Integration Notes

- Notes are separate from task management (tskr commands)
- NOTES.md is typically gitignored (as seen in global gitignore)
- Can be used alongside tskr system for different types of information
- Useful for capturing context that doesn't warrant a full task

## Advanced Features

### Smart Content Detection
Automatically suggest categories based on note content:
- Contains "bug", "error", "broken" → suggest `bug`
- Contains "idea", "could", "maybe" → suggest `idea`  
- Contains "todo", "remember", "need to" → suggest `todo`
- Contains "question", "why", "how" → suggest `question`

### Note Search
When reading existing NOTES.md, provide quick summary:
- Total number of notes
- Most recent note date
- Category breakdown if categories are used

## Error Handling

- **File write errors**: Check permissions and disk space
- **Invalid category**: Show valid category options
- **Empty note**: Require minimum content length
- **Malformed existing file**: Attempt to append safely