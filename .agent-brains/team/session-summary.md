# Session Summary — DevDogs.Templates A-pilot Team
**Date:** 2026-04-29  
**Repo:** https://github.com/DevilDogTG/DevDogs.Templates  
**All todos: 54/54 DONE**

---

## What Was Built

### 1. NuGet Template Pack (`DevDogs.Templates`)
- `templatepack.csproj` — pack manifest (net9.0, PackageType=Template)
- 4 `dotnet new` templates:
  | Short Name | Description |
  |---|---|
  | `devdogs-webapi` | Minimal API + Serilog + clean DI |
  | `devdogs-service` | Interface + class item template |
  | `devdogs-avalonia` | Avalonia MVVM + Fluent + CommunityToolkit.Mvvm |
  | `devdogs-graphql` | HotChocolate GraphQL + Serilog |
- Pack: `dotnet pack --no-build -o ./nupkg`
- All 8 template instantiation tests PASS

### 2. A-pilot Team Structure (`.agent-brains/`)
```
.agent-brains/
  AGENT.md                          # workspace rules for all agents
  team/
    roles.md                        # Planner / Developer / Tester / Reviewer prompts
    fleet-workflow.md               # how to use /fleet + parallel agents
    lifecycle-guide.md              # issue lifecycle: labels, who sets them, flow
    recurring-agent-setup.md        # cron + schtasks scheduling guide
    plan/
      backlog.md
      dotnet-templates.md           # 17-todo atomic plan (all done)
    scripts/
      triage-agent.sh               # ← THE MAIN SCRIPT
      triage-report.md.tpl          # rich per-issue triage comment template
      status-dashboard.md.tpl       # dashboard body template
      triage-status-issue           # contains "2" (dashboard issue number)
```

### 3. Triage Agent (`triage-agent.sh`)
Runs every 30 min via cron. Does:
1. **Issue triage** — labels unlabeled issues (bug/feature/question/triage by keyword)
2. **PR triage** — labels unlabeled PRs with `needs-review`
3. **Needs-review scanner** — reminds every 1 hour per issue using `~/.copilot/logs/triage-reminded.tsv`
4. **Done auto-close** — closes open issues labelled `done`, posts closure comment
5. **Dashboard update** — edits issue #2 body in-place with latest run stats + needs-review queue
6. **Dashboard comment** — posts run summary comment on issue #2 when real work happened

### 4. GitHub Setup
- Repo: `DevilDogTG/DevDogs.Templates` (public)
- Labels created: `bug`, `feature`, `question`, `triage`, `automation`, `in-progress`, `needs-review`, `done`
- Issue #2: 🤖 Triage Agent — Status Dashboard (pinned, `automation` label)
- Issue #1: test issue used to validate the full lifecycle

---

## Crontab (current)
```
*/30 * * * * PATH=/usr/bin:/bin HOME=/home/devildogtug /mnt/r/DevDogs/test/.agent-brains/team/scripts/triage-agent.sh >> /home/devildogtug/.copilot/logs/triage-agent.log 2>&1
```
Auth: script self-loads `~/.config/gh/pat_token` when `GH_TOKEN` not set.

## Local State Files
| File | Purpose |
|---|---|
| `~/.copilot/logs/triage-agent.log` | full run log |
| `~/.copilot/logs/triage-agent-history.tsv` | per-run stats (used for dashboard history table) |
| `~/.copilot/logs/triage-reminded.tsv` | tracks last reminder timestamp per issue number |
| `~/.config/gh/pat_token` | GH token for cron auth |

---

## Issue Lifecycle (how it works)
```
New issue created
  → agent auto-labels (bug/feature/question/triage) + posts triage comment
  → dev sets in-progress when starting work
  → dev sets needs-review when ready
  → agent posts ⏰ reminder every 1 hour until reviewed
  → reviewer sets done
  → agent auto-closes with summary comment (next cron run, ≤30 min)
```

---

## Bugs Fixed This Session
1. Crontab had wrong script path (`/repositories/` → `/mnt/r/`)
2. Crontab used `cat ~/.config/gh/token` (file didn't exist) → fixed with self-loading PAT
3. Duplicate cron entries causing parallel runs
4. `--jq '.[]'` gave multi-line JSON; loop parsed single lines → fixed with `| jq -c '.[]'`
5. Reminder used `updatedAt` — posting comment reset the clock → fixed with local TSV tracking
6. `(( var++ ))` exits with code 1 when var=0 under `set -e` → fixed with `var=$(( var + 1 ))`

---

## Possible Next Tasks
- Publish NuGet package to nuget.org
- Add more templates (Blazor, gRPC, Worker Service, etc.)
- Expand triage keywords / classification logic
- Add `stale` label + auto-close for old issues with no activity
- GitHub Actions alternative if local cron unavailable
- Multi-repo support in triage agent
