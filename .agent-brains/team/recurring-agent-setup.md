# Recurring Agent — Local Schedule Setup

## Concept

The Copilot CLI is an interactive tool, so recurring automation is achieved by writing a bash script that embodies the agent role's logic using the `gh` CLI, then scheduling that script locally via cron (Linux/macOS) or Task Scheduler (Windows). The script **is** the agent — it reads repository context (open issues, PRs, labels), makes decisions using conditional logic, and takes actions (commenting, labeling, assigning) entirely through `gh` CLI commands. No interactive session is required; the schedule replaces the human trigger.

---

## Prerequisites

- `gh` CLI installed and authenticated (`gh auth login`)
- `jq` installed (for JSON parsing in scripts)
- Script path: `.agent-brains/team/scripts/triage-agent.sh` (must be made executable before scheduling)

---

## Setup

### Make script executable (all platforms)

```bash
chmod +x .agent-brains/team/scripts/triage-agent.sh
```

---

### Linux / macOS — crontab

#### Step-by-step

1. **Open the crontab editor:**
   ```bash
   crontab -e
   ```

2. **Add the scheduling line**, replacing `/path/to/repo` with the absolute path to your repository root (e.g., `/mnt/r/DevDogs/test`).

3. **GH_TOKEN note:** cron runs in a minimal environment and does **not** inherit your shell's environment variables. You must supply `GH_TOKEN` explicitly in the crontab line. Two safe approaches:
   - Read it from the `gh` CLI token file at runtime: `GH_TOKEN=$(cat ~/.config/gh/hosts.yml | grep 'oauth_token' | awk '{print $2}')` — or store the raw token in a dedicated file like `~/.config/gh/token` and use `$(cat ~/.config/gh/token)`.
   - Export it from a sourced credentials file: `source ~/.profile &&` prepended to the command.

4. **Full crontab entry** (`*/30 * * * *` means "run at minute 0 and every 30th minute past the hour" — i.e., every 30 minutes):
   ```
   */30 * * * * GH_TOKEN=$(cat ~/.config/gh/token) /path/to/repo/.agent-brains/team/scripts/triage-agent.sh >> ~/.copilot/logs/triage-agent.log 2>&1
   ```

   > **Cron schedule syntax:** `*/30 * * * *`
   > | Field | Value | Meaning |
   > |-------|-------|---------|
   > | Minute | `*/30` | Every 30 minutes |
   > | Hour | `*` | Every hour |
   > | Day of month | `*` | Every day |
   > | Month | `*` | Every month |
   > | Day of week | `*` | Every day of week |

5. **Verify the entry was saved:**
   ```bash
   crontab -l
   ```

6. **View live logs:**
   ```bash
   tail -f ~/.copilot/logs/triage-agent.log
   ```
   > Create the log directory first if it doesn't exist: `mkdir -p ~/.copilot/logs`

7. **Remove the schedule:**
   ```bash
   crontab -e
   ```
   Then delete the line containing `triage-agent.sh` and save.

---

### Windows — Task Scheduler (schtasks)

Two options depending on your shell environment. **WSL is recommended** if installed, as it gives full bash compatibility.

#### Option A: WSL (Recommended)

Run from **Command Prompt** or **PowerShell**:

```cmd
schtasks /create /tn "DevDogs Triage Agent" /tr "wsl bash /mnt/r/DevDogs/test/.agent-brains/team/scripts/triage-agent.sh" /sc minute /mo 30 /ru "%USERNAME%"
```

> **WSL path mapping:** Windows `R:\DevDogs\test` maps to `/mnt/r/DevDogs/test` inside WSL. Adjust the drive letter and path if your repo is elsewhere.

#### Option B: Git Bash

Run from **Command Prompt** or **PowerShell**:

```cmd
schtasks /create /tn "DevDogs Triage Agent" /tr "\"C:\Program Files\Git\bin\bash.exe\" -c \"/r/DevDogs/test/.agent-brains/team/scripts/triage-agent.sh\"" /sc minute /mo 30 /ru "%USERNAME%"
```

> Adjust `C:\Program Files\Git\bin\bash.exe` if Git is installed to a different location. Check with: `where bash`

#### Managing the scheduled task

```cmd
:: View task details
schtasks /query /tn "DevDogs Triage Agent"

:: Run immediately (useful for testing)
schtasks /run /tn "DevDogs Triage Agent"

:: Delete the task
schtasks /delete /tn "DevDogs Triage Agent" /f
```

#### GH_TOKEN on Windows

Task Scheduler does not automatically inherit user environment variables. Add `GH_TOKEN` as a persistent **User Environment Variable**:

1. Open **System Properties** → **Advanced** tab → **Environment Variables**
2. Under **User variables**, click **New**
3. Set **Variable name:** `GH_TOKEN`
4. Set **Variable value:** your GitHub Personal Access Token
5. Click **OK** and restart any open terminals

Alternatively, set it via PowerShell (persists across sessions):
```powershell
[System.Environment]::SetEnvironmentVariable("GH_TOKEN", "your_token_here", "User")
```

---

### Logs

| Platform | Log path |
|----------|----------|
| Linux / macOS / WSL | `~/.copilot/logs/triage-agent.log` |
| Windows (native) | `%USERPROFILE%\.copilot\logs\triage-agent.log` |

**Create the log directory (Linux/macOS/WSL):**
```bash
mkdir -p ~/.copilot/logs
```

**View the last 50 lines:**
```bash
tail -50 ~/.copilot/logs/triage-agent.log
```

**Follow live output:**
```bash
tail -f ~/.copilot/logs/triage-agent.log
```

---

## Extending to Other Agent Roles

Any agent role can be scripted using this same pattern. The core insight is:

> **"Agent role" = a script with a defined responsibility, inputs (`gh` CLI queries), decisions (`if`/`else` logic), and outputs (`gh` CLI commands).**

Each script is a self-contained, headless agent that can be independently scheduled:

- **Developer agent** — Queries for issues labeled `feature` with no linked branch and auto-creates a `feature/<slug>` branch via `gh` CLI.
- **Reviewer agent** — Scans open PRs labeled `needs-review` that have no assigned reviewer, then calls `gh pr edit --add-reviewer` to request one.
- **Notifier agent** — Aggregates daily activity (merged PRs, closed issues, new comments) and posts a summary payload to a Slack or Teams webhook via `curl`.
- **Stale issue agent** — Identifies issues with no activity in N days and applies a `stale` label with a comment warning of auto-closure.

To add a new agent role:

1. Create the script: `.agent-brains/team/scripts/<role>-agent.sh`
2. Make it executable: `chmod +x .agent-brains/team/scripts/<role>-agent.sh`
3. Add a separate cron line (or Task Scheduler task) with the appropriate schedule
4. Log to a role-specific file: `~/.copilot/logs/<role>-agent.log`

This keeps each agent's schedule, logic, and logs independent and easy to debug or disable without affecting other roles.
