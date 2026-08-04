# Sol Advisor

This repository ships one native Hermes Agent skill. The primary session owns
architecture, task packets, monitoring, actual diff inspection, correction,
verification, and acceptance; implementation is routed through Hermes
`delegate_task`.

## Required verification

Run from the repository root:

```sh
sh scripts/verify.sh
git diff --check
```

## Repository map

- [Hermes skill](skills/software-development/sol-advisor/SKILL.md) — authoritative workflow and task-packet contract.
- [Focused verifier](scripts/verify.sh) — structure and stale-artifact checks.
- [Development guidance](docs/agent-instructions/development.md) — layout and setup.
- [Orchestration guidance](docs/agent-instructions/orchestration.md) — delegation and acceptance rules.
- [Validation guidance](docs/agent-instructions/validation.md) — runnable checks and link expectations.

## Working rules

- Read the skill before changing orchestration behavior.
- Configure delegation with `hermes config set`; never hand-edit Hermes configuration.
- Preserve concurrent user edits and inspect the complete diff before acceptance.
- Do not commit or push unless the current task explicitly requests it.
