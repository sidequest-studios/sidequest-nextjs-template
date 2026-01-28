# Ralph - Autonomous Coding Loop

Ralph is an autonomous AI coding loop that works through a list of tasks while you're away. Each iteration is a fresh context window, with memory persisting via git history and text files.

## File Structure

```
scripts/ralph/
├── ralph.sh       # Main AFK loop (runs up to N iterations)
├── ralph-once.sh  # Single iteration for HITL mode
├── prompt.md      # Instructions for each iteration
├── prd.json       # Task list (edit this for your feature)
└── progress.txt   # Progress tracker with codebase patterns
```

## Quick Start

### 1. Define your tasks

Edit `prd.json` with your user stories:

```json
{
  "branchName": "ralph/your-feature",
  "userStories": [
    {
      "id": "US-001",
      "title": "Add login button",
      "acceptanceCriteria": [
        "Button appears on home screen",
        "Navigates to auth flow on press",
        "bun lint passes",
        "bun typecheck passes"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
```

**Tips for good stories:**
- Keep them small (one context window each)
- Be explicit about acceptance criteria
- Include feedback loop requirements (`bun lint`, `bun typecheck`)
- Higher priority = lower number

### 2. Create your feature branch

```bash
git checkout -b ralph/your-feature-name
```

### 3. Run Ralph

**HITL mode** (human-in-the-loop) - watch and intervene:
```bash
./scripts/ralph/ralph-once.sh
```

**AFK mode** (away-from-keyboard) - streams output in real-time:
```bash
./scripts/ralph/ralph.sh 10    # up to 10 iterations
./scripts/ralph/ralph.sh 25    # up to 25 iterations
```

> **Note:** AFK mode uses `--output-format stream-json` with `jq` filtering to stream Claude's responses in real-time. You can watch progress as it happens, even when running unattended. Requires `jq` to be installed.

## Monitoring Progress

With streaming enabled, you'll see Claude's responses in real-time as it works. For additional monitoring:

```bash
# Check task status
cat scripts/ralph/prd.json | jq '.userStories[] | {id, title, passes}'

# View learnings
cat scripts/ralph/progress.txt

# See commits
git log --oneline -10

# Watch progress file (in another terminal)
tail -f scripts/ralph/progress.txt
```

## How It Works

Each iteration:
1. Reads `prd.json` to see what tasks exist
2. Reads `progress.txt` to see what's been done
3. Picks the highest priority incomplete task
4. Implements that ONE task
5. Runs feedback loops (`bun lint`, `bun typecheck`, `bun run test`)
6. Commits if passing
7. Updates `prd.json` to mark task complete
8. Appends learnings to `progress.txt`
9. Loop repeats until all tasks pass

## Writing prd.json

The PRD (Product Requirements Document) is how you tell Ralph what to build.

### Structure

```json
{
  "branchName": "ralph/feature-name",
  "userStories": [
    {
      "id": "US-001",
      "title": "Short description of the task",
      "acceptanceCriteria": [
        "Specific, verifiable requirement",
        "Another requirement",
        "bun lint passes",
        "bun typecheck passes"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
```

### Fields Explained

| Field | Purpose |
|-------|---------|
| `branchName` | Git branch Ralph works on. Create it before running. |
| `id` | Unique identifier (US-001, US-002, etc.) |
| `title` | Short task description. Used in commit messages. |
| `acceptanceCriteria` | How Ralph knows it's done. Be explicit. |
| `priority` | Lower number = higher priority. Ralph picks lowest. |
| `passes` | Ralph sets to `true` when complete. |
| `notes` | Ralph can add notes if blocked. You can add hints here too. |

### Sizing Stories: The Golden Rule

Each story must fit in **one context window**. If it's too big, Ralph will lose context mid-task and produce poor results.

**Too big (will fail):**
```json
{
  "id": "US-001",
  "title": "Add user authentication system",
  "acceptanceCriteria": ["Users can sign up, log in, reset password"]
}
```

**Right size (will succeed):**
```json
{
  "id": "US-001",
  "title": "Add auth context provider",
  "acceptanceCriteria": [
    "AuthProvider in src/providers/auth-provider.tsx",
    "useAuth hook returns { user, signIn, signOut }",
    "Wraps app in src/app/layout.tsx",
    "bun typecheck passes"
  ]
},
{
  "id": "US-002",
  "title": "Add sign in form",
  "acceptanceCriteria": [
    "SignInForm component in src/components/sign-in-form.tsx",
    "Email and password inputs",
    "Calls useAuth().signIn on submit",
    "bun lint passes"
  ]
}
```

### Writing Good Acceptance Criteria

**Vague (Ralph will cut corners):**
```json
"acceptanceCriteria": ["Users can add labels to items"]
```

**Explicit (Ralph knows exactly what to do):**
```json
"acceptanceCriteria": [
  "LabelPicker component in src/components/label-picker.tsx",
  "Shows all available labels",
  "Supports multi-select with checkboxes",
  "Calls onSelect callback with selected label IDs",
  "bun lint passes",
  "bun typecheck passes"
]
```

### Prioritization Strategy

Lower priority number = Ralph works on it first.

**Priority 1-2: Architectural/Risky**
- Schema changes
- New providers/contexts
- Core abstractions

**Priority 3-4: Implementation**
- API routes
- UI components
- Pages

**Priority 5+: Polish**
- Error handling
- Loading states
- Edge cases

## Best Practices

### Story Sizing
- **Too big**: "Build entire auth system"
- **Right size**: "Add login form", "Add email validation", "Add auth API route"

### Feedback Loops
Ralph won't commit if these fail:
- `bun lint` - lint and format
- `bun typecheck` - TypeScript
- `bun run test` - tests (if configured)

### Progress File
Ralph appends learnings after each task. Patterns accumulate and inform future iterations. Delete `progress.txt` after completing your sprint (it's session-specific).

## Prerequisites

- **jq**: Required for streaming output in AFK mode. Install with `brew install jq` (macOS) or `apt install jq` (Linux).
- **claude**: Claude Code CLI must be installed and authenticated.

## Troubleshooting

**Ralph keeps looping without progress**
- Check if feedback loops are failing
- Stories might be too vague - add explicit acceptance criteria
- Check `progress.txt` for error patterns

**Ralph skipped a task**
- It might have decided it was blocked - check the `notes` field in prd.json
- Re-run with that task as highest priority

**Ralph marked something complete but it's not right**
- Set `passes: false` in prd.json
- Add notes explaining what's wrong
- Re-run

## Cleanup

After your feature is complete:
1. Review all commits: `git log --oneline`
2. Squash if needed: `git rebase -i main`
3. Delete progress.txt (it's session-specific)
4. Reset prd.json for next feature

## Credits

Based on the Ralph Wiggum pattern by [@GeoffreyHuntley](https://twitter.com/GeoffreyHuntley).
