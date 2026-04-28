# Workspace Agent Directives

Inherits from: `/mnt/g/My Drive/Personal/Agent/Brains/GLOBAL_AGENT.md`

## Project
Name: test
Type: starter

## A-Pilot Team
This workspace uses an autonomous agent team. See `.agent-brains/team/` for role definitions.

## Active Team
- **Planner** — breaks down tasks, writes plan to `.agent-brains/plan/`
- **Developer** — implements features, follows plan
- **Tester** — runs builds/tests, reports results
- **Reviewer** — validates code quality, flags issues

## Rules
- All agents MUST read the current `plan/backlog.md` before starting work
- Developers MUST NOT skip failed tests
- Reviewer runs AFTER Tester passes
