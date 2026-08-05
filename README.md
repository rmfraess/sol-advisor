# Sol Advisor

Sol Advisor is a native Hermes Agent plugin that bundles the existing Sol
Advisor skill and injects its orchestration policy into every top-level Hermes
turn. The primary session owns architecture, task packets, monitoring, actual
diff inspection, correction, verification, and acceptance; implementation is
routed through native Hermes `delegate_task`.

## Install

Install and enable the plugin from the repository:

```sh
hermes plugins install rmfraess/sol-advisor --enable
```

Restart Hermes after installation. Plugins load when a Hermes process starts;
restart any running CLI, gateway, or desktop session before testing the global
behavior. The plugin registers the existing skill as
`sol-advisor:sol-advisor`; do not install a second copy with `hermes skills
install`.

## Global behavior

The plugin's `pre_llm_call` hook injects a short policy into every top-level
turn. It requires `sol-advisor:sol-advisor` to be loaded before implementation,
refactoring, or debugging; keeps design, review, verification, correction, and
acceptance in the primary session; and routes implementation through native
`delegate_task`. Read-only questions and non-code operations remain exempt.

Delegated children are detected from Hermes' `parent_session_id` hook argument,
so they do not receive a duplicate policy injection. The plugin keeps no
process-global child state and does not classify children by model name.

The `pre_tool_call` hook only inspects `delegate_task`. It blocks the call unless
all three resolved delegation values match exactly:

```text
delegation.model = gpt-5.6-luna
delegation.provider = openai-codex
delegation.reasoning_effort = max
```

Other tools pass through. The hook never edits Hermes configuration. Repair a
mismatch with Hermes commands:

```sh
hermes config set delegation.model gpt-5.6-luna
hermes config set delegation.provider openai-codex
hermes config set delegation.reasoning_effort max
```

## Use

Ask the primary Hermes session to use Sol Advisor for an implementation task.
The primary session must:

1. settle requirements, architecture, ownership, and verification;
2. send a complete task packet to `delegate_task`;
3. inspect the actual working tree and complete diff after the child reports;
4. rerun verification and send a new precise delegation for any correction; and
5. accept the result only after the evidence matches the packet.

Independent, non-overlapping packets may be batched. Shared-file or dependent
work stays serial. Child reports are evidence to inspect, not acceptance.

See the [orchestration flow diagram](docs/sol-advisor-flow.md) for the complete
primary-to-child lifecycle and correction loop.

## Local verification

From the repository root:

```sh
python -m unittest discover -s tests -p 'test_plugin.py'
sh scripts/verify.sh
git diff --check
```

The focused verifier uses POSIX shell utilities, works from Git Bash on Windows,
and checks the plugin manifest, entry point, bundled skill, focused tests, and
absence of stale legacy routing artifacts.

## Repository layout

- `plugin.yaml` — installable Hermes plugin manifest.
- `__init__.py` — plugin entry point, policy hooks, and bundled-skill registration.
- `skills/software-development/sol-advisor/SKILL.md` — the reused Hermes skill.
- `tests/test_plugin.py` — focused stdlib hook and route-gating tests.
- `scripts/verify.sh` — the narrow repository structure and routing verifier.
- `.hermes.md` — automatic Hermes session bootstrap for this repository.
- `AGENTS.md` — progressive-disclosure project instructions.
- `docs/sol-advisor-flow.md` — visual orchestration and acceptance flow.
- `docs/agent-instructions/` — development, orchestration, and validation details.

## License

MIT
