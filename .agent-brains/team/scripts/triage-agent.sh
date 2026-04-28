#!/usr/bin/env bash
# =============================================================================
# triage-agent.sh — A-pilot Planner Role: GitHub Issue & PR Triage
# =============================================================================
# Automatically labels unlabeled GitHub issues and PRs, then posts a triage
# comment using the co-located triage-report.md.tpl template.
#
# Usage:
#   chmod +x triage-agent.sh
#   ./triage-agent.sh
#
# Dependencies: gh (GitHub CLI, authenticated), jq
# =============================================================================
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
REPO="DevilDogTG/DevDogs.Templates"
LOG_DIR="$HOME/.copilot/logs"
LOG_FILE="$LOG_DIR/triage-agent.log"
HISTORY_FILE="$LOG_DIR/triage-agent-history.tsv"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$SCRIPT_DIR/triage-report.md.tpl"
DASHBOARD_TPL="$SCRIPT_DIR/status-dashboard.md.tpl"
STATUS_ISSUE_FILE="$SCRIPT_DIR/triage-status-issue"
STATUS_ISSUE=""

# ---------------------------------------------------------------------------
# Bootstrap
# ---------------------------------------------------------------------------
mkdir -p "$LOG_DIR"

# Logging helper — writes timestamped output to stdout AND the log file.
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# ---------------------------------------------------------------------------
# Dependency checks
# ---------------------------------------------------------------------------
if ! command -v gh &>/dev/null; then
    log "ERROR: 'gh' CLI is not installed or not on PATH. Install it from https://cli.github.com/"
    exit 1
fi

if ! command -v jq &>/dev/null; then
    log "ERROR: 'jq' is not installed. Install it with: sudo apt install jq  OR  brew install jq"
    exit 1
fi

if [[ ! -f "$TEMPLATE" ]]; then
    log "ERROR: Comment template not found at: $TEMPLATE"
    exit 1
fi

# Load status issue number (optional — skip dashboard update if not configured)
if [[ -f "$STATUS_ISSUE_FILE" ]]; then
    STATUS_ISSUE="$(cat "$STATUS_ISSUE_FILE" | tr -d '[:space:]')"
    log "Status dashboard issue: #${STATUS_ISSUE}"
else
    log "WARN: triage-status-issue config not found — dashboard update skipped."
fi

# ---------------------------------------------------------------------------
# Helper: build recent history table from TSV log
# ---------------------------------------------------------------------------
build_history_table() {
    if [[ ! -f "$HISTORY_FILE" ]] || [[ ! -s "$HISTORY_FILE" ]]; then
        echo "_No history yet._"
        return
    fi
    echo "| Run time | Issues triaged | PRs flagged | Status |"
    echo "|---|---|---|---|"
    tail -5 "$HISTORY_FILE" | while IFS=$'\t' read -r ts issues prs status; do
        echo "| $ts | $issues | $prs | $status |"
    done
}

# ---------------------------------------------------------------------------
# Helper: update the GitHub status dashboard issue
# ---------------------------------------------------------------------------
# Args: $1=issues_triaged $2=prs_flagged $3=status_emoji
update_status_issue() {
    [[ -z "$STATUS_ISSUE" ]] && return
    local issues="$1" prs="$2" status="$3"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S %Z')"

    # Append to local history TSV
    echo -e "${timestamp}\t${issues}\t${prs}\t${status}" >> "$HISTORY_FILE"

    local history_table
    history_table="$(build_history_table)"

    local body
    body="$(sed \
        -e "s/{{TIMESTAMP}}/${timestamp}/g" \
        -e "s/{{ISSUES_TRIAGED}}/${issues}/g" \
        -e "s/{{PRS_FLAGGED}}/${prs}/g" \
        -e "s/{{STATUS}}/${status}/g" \
        "$DASHBOARD_TPL")"

    # Inject history table (multi-line sed workaround via awk)
    body="$(echo "$body" | awk -v hist="$history_table" '{gsub(/\{\{HISTORY_TABLE\}\}/, hist); print}')"

    gh issue edit "$STATUS_ISSUE" --repo "$REPO" --body "$body"
    log "Status dashboard updated → https://github.com/${REPO}/issues/${STATUS_ISSUE}"
}

# ---------------------------------------------------------------------------
# Helper: render and post a triage comment from the template
# ---------------------------------------------------------------------------
# Args: $1=number $2=label
post_triage_comment() {
    local number="$1"
    local label="$2"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S %Z')"

    # Render template by replacing placeholders via sed
    local body
    body="$(sed \
        -e "s/{{ISSUE_NUMBER}}/${number}/g" \
        -e "s/{{LABEL}}/${label}/g" \
        -e "s/{{TIMESTAMP}}/${timestamp}/g" \
        "$TEMPLATE")"

    gh issue comment "$number" --repo "$REPO" --body "$body"
}

# ---------------------------------------------------------------------------
# Helper: classify a title string into a label
# ---------------------------------------------------------------------------
# Prints one of: bug | feature | question | triage
classify_title() {
    local title_lower
    title_lower="$(echo "$1" | tr '[:upper:]' '[:lower:]')"

    if echo "$title_lower" | grep -qE 'bug|error|fix|crash|fail'; then
        echo "bug"
    elif echo "$title_lower" | grep -qE 'feat|add|new|request|enhance'; then
        echo "feature"
    elif echo "$title_lower" | grep -qE 'how|why|question|help|docs'; then
        echo "question"
    else
        echo "triage"
    fi
}

# ---------------------------------------------------------------------------
# Issue Triage
# ---------------------------------------------------------------------------
log "========================================"
log "Starting issue triage for repo: $REPO"
log "========================================"

issues_triaged=0

# Fetch all open issues that currently have no labels applied
unlabeled_issues="$(gh issue list \
    --repo "$REPO" \
    --json number,title,labels \
    --jq '[.[] | select(.labels | length == 0)]')"

issue_count="$(echo "$unlabeled_issues" | jq 'length')"
log "Found $issue_count unlabeled open issue(s)."

if [[ "$issue_count" -gt 0 ]]; then
    # Iterate over each issue object in the JSON array
    while IFS= read -r issue; do
        number="$(echo "$issue" | jq -r '.number')"
        title="$(echo "$issue"  | jq -r '.title')"

        # Skip the status dashboard issue itself
        [[ "$number" == "$STATUS_ISSUE" ]] && continue

        label="$(classify_title "$title")"

        log "Issue #${number}: \"${title}\" → applying label '${label}'"

        # Apply the chosen label to the issue
        gh issue edit "$number" --repo "$REPO" --add-label "$label"

        # Post the structured triage comment
        post_triage_comment "$number" "$label"

        (( issues_triaged++ ))
    done < <(echo "$unlabeled_issues" | jq -c '.[]')
fi

# ---------------------------------------------------------------------------
# PR Triage
# ---------------------------------------------------------------------------
log "========================================"
log "Starting PR triage for repo: $REPO"
log "========================================"

prs_flagged=0

# Fetch all open PRs that currently have no labels applied
unlabeled_prs="$(gh pr list \
    --repo "$REPO" \
    --json number,title,labels \
    --jq '[.[] | select(.labels | length == 0)]')"

pr_count="$(echo "$unlabeled_prs" | jq 'length')"
log "Found $pr_count unlabeled open PR(s)."

if [[ "$pr_count" -gt 0 ]]; then
    while IFS= read -r pr; do
        number="$(echo "$pr" | jq -r '.number')"
        title="$(echo "$pr"  | jq -r '.title')"

        log "PR #${number}: \"${title}\" → applying label 'needs-review'"

        # Label the PR for review
        gh pr edit "$number" --repo "$REPO" --add-label "needs-review"

        # Post a short, direct review-flagging comment
        gh pr comment "$number" --repo "$REPO" \
            --body "👀 This PR has been flagged for review by the triage agent."

        (( prs_flagged++ ))
    done < <(echo "$unlabeled_prs" | jq -c '.[]')
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
log "========================================"
log "Triage complete."
log "  Issues triaged : $issues_triaged"
log "  PRs flagged    : $prs_flagged"
log "========================================"

# Update the GitHub status dashboard issue in-place
update_status_issue "$issues_triaged" "$prs_flagged" "✅ Completed"
