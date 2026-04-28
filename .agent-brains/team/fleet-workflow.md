# A-Pilot Fleet Workflow

## How to Run the Team in Copilot CLI

### Step 1 — Enable Fleet + Autopilot
```
/fleet
/experimental        ← enables Autopilot mode
Shift+Tab            ← cycle to Autopilot mode
```

### Step 2 — Kick off the Planner
Paste this prompt directly into Copilot CLI:
```
Act as the Planner role from .agent-brains/team/roles.md.
Task: [describe your feature here]
```

### Step 3 — Hand off to Developer (parallel or sequential)
```
Act as the Developer role from .agent-brains/team/roles.md.
```

### Step 4 — Run Tester
```
Act as the Tester role from .agent-brains/team/roles.md.
```

### Step 5 — Run Reviewer (after Tester passes)
```
Act as the Reviewer role from .agent-brains/team/roles.md.
```

---

## Parallel Execution with /fleet

Use `/fleet` to run Planner + Researcher in parallel on a complex task:

```
/fleet

Agent 1 → "Act as Planner: break down [TASK] and write backlog.md"
Agent 2 → "Act as Researcher: explore the codebase and summarize 
           relevant modules for [TASK]"
```
Wait for both → hand result to Developer.

---

## One-Shot Full Run (Autopilot)

Enable Autopilot (Shift+Tab), then send:
```
Using roles in .agent-brains/team/roles.md, run the full A-pilot 
pipeline for this task: [TASK]

Order: Planner → Developer → Tester → Reviewer
Do not stop between steps unless Tester fails.
```
Copilot will self-direct through each role until done.
