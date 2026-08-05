# Sol Advisor

This repository ships a native Hermes Agent plugin that bundles the Sol Advisor
skill and globally injects its orchestration policy into every top-level turn.
The primary session owns architecture, task packets, monitoring, actual diff
inspection, correction, verification, and acceptance; implementation is routed
through Hermes `delegate_task`.

## Required verification

Run from the repository root:

```sh
python -m unittest discover -s tests -p 'test_plugin.py'
sh scripts/verify.sh
git diff --check
```

## Repository map

- [Plugin manifest](plugin.yaml) — directly installable Hermes plugin metadata.
- [Plugin entry point](__init__.py) — global policy hooks and skill registration.
- [Hermes skill](skills/software-development/sol-advisor/SKILL.md) — authoritative workflow and task-packet contract.
- [Focused plugin tests](tests/test_plugin.py) — stdlib hook and route-gating coverage.
- [Orchestration diagram](docs/sol-advisor-flow.md) — visual primary, child, correction, and publication flow.
- [Focused verifier](scripts/verify.sh) — plugin structure and stale-artifact checks.
- [Development guidance](docs/agent-instructions/development.md) — layout and setup.
- [Orchestration guidance](docs/agent-instructions/orchestration.md) — delegation and acceptance rules.
- [Validation guidance](docs/agent-instructions/validation.md) — runnable checks and link expectations.

## Working rules

- Read the skill before changing orchestration behavior.
- The installed plugin injects policy for top-level turns; load `sol-advisor:sol-advisor` before implementation, refactoring, or debugging.
- Configure delegation with `hermes config set`; never hand-edit Hermes configuration.
- Preserve concurrent user edits and inspect the complete diff before acceptance.
- Do not commit or push unless the current task explicitly requests it.
