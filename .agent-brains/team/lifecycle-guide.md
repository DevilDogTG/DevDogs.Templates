# Issue Lifecycle Guide

## Overview

Every issue in this repo follows a clear lifecycle managed by the A-pilot triage agent and the team.

```
[Created] → [Triaged] → [In Progress] → [Needs Review] → [Done / Closed]
```

---

## Label Lifecycle

| Label | Who sets it | Meaning |
|---|---|---|
| `bug` / `feature` / `question` / `triage` | 🤖 Triage agent (auto) | Issue has been classified |
| `in-progress` | 👤 Assignee (manual) | Work has started |
| `needs-review` | 👤 Developer (manual) OR 🤖 PR merged | Work is done, needs a reviewer |
| `done` | 👤 Reviewer (manual) | Verified complete — agent auto-closes |
| `automation` | 🤖 Agent (reserved) | Internal agent use — do not triage |

---

## How to Know an Issue is Done

### Option A — Label flow (recommended for issues without PRs)
1. Developer sets `needs-review` label
2. Reviewer checks the work
3. Reviewer sets `done` label
4. **Triage agent detects `done` label → posts closure summary → closes the issue**

### Option B — PR with Closes keyword (recommended for code changes)
1. Developer opens a PR with `Closes #N` in the description
2. PR is reviewed and merged
3. **GitHub auto-closes the linked issue on merge**
4. Triage agent detects closed issues and posts a summary comment

---

## How Reviewers Are Notified

When an issue gets the `needs-review` label:
- The triage agent scans for `needs-review` issues every 30 minutes
- It posts a **reminder comment** on the issue if it has been waiting > 1 hour
- It also lists all `needs-review` items in the **Status Dashboard** (issue #2)

---

## Status Dashboard (Issue #2)

The triage agent updates **issue #2** body after every run:
- Latest run summary (issues triaged, PRs flagged)
- `needs-review` queue — issues waiting for a reviewer
- Last 5 run history

**A comment is posted on issue #2 when something meaningful happens** (e.g., issues were triaged, PRs flagged, or `done` issues closed).

---

## Quick Reference

```bash
# Start work on an issue
gh issue edit <N> --repo DevilDogTG/DevDogs.Templates --add-label "in-progress"

# Mark ready for review
gh issue edit <N> --repo DevilDogTG/DevDogs.Templates \
  --remove-label "in-progress" --add-label "needs-review"

# Mark done (triggers auto-close by agent)
gh issue edit <N> --repo DevilDogTG/DevDogs.Templates --add-label "done"
```
