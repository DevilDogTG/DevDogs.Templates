🤖 **Triage Agent** — Issue Triaged

| Field | Value |
|---|---|
| Issue | #{{ISSUE_NUMBER}} |
| Label applied | `{{LABEL}}` |
| Triaged at | {{TIMESTAMP}} |
| Status | 🔵 Open — awaiting action |

---

### 📋 What happens next?

**For the assignee / developer:**
- [ ] Add `in-progress` label when you start working
- [ ] Remove `in-progress`, add `needs-review` when work is done (or open a PR with `Closes #{{ISSUE_NUMBER}}`)
- [ ] The reviewer adds `done` label after approving — the agent will close this issue automatically

**For reviewers:**
- Watch for the `needs-review` label — the triage agent will post a reminder if it lingers

> 🔁 **Lifecycle:** `triage/bug/feature` → `in-progress` → `needs-review` → `done` (auto-closed)
>
> To override this triage, change the label manually and remove `triage` if present.

