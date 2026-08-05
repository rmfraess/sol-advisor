# Development

## Layout

- `plugin.yaml`: directly installable Hermes plugin manifest.
- `__init__.py`: plugin entry point, global hooks, and bundled skill registration.
- `skills/software-development/sol-advisor/SKILL.md`: reused Hermes skill.
- `tests/test_plugin.py`: focused stdlib tests for registration, injection, and route gating.
- `.hermes.md`: repository-wide Hermes bootstrap that loads `AGENTS.md` and the qualified skill.
- `scripts/verify.sh`: the repository structure, plugin, and stale-artifact verifier.
- `README.md`: installation and user-facing configuration.
- `docs/agent-instructions/`: progressive-disclosure project guidance.

## Toolchain

There is no application runtime, package manifest, dependency install, build, or
compiled artifact. The plugin uses only Python stdlib code plus Hermes runtime
APIs. Use a POSIX shell for repository checks; the focused tests use `unittest`
and `scripts/verify.sh` uses `python` with a `python3` fallback.

## Installation

Install and enable the plugin with:

```sh
hermes plugins install rmfraess/sol-advisor --enable
hermes config set delegation.model gpt-5.6-luna
hermes config set delegation.provider openai-codex
hermes config set delegation.reasoning_effort max
```

Restart running Hermes processes after installation because plugins load at
startup. The plugin registers the reused skill as
`sol-advisor:sol-advisor`; do not manually edit a Hermes profile or install a
second flat skill copy.

Do not add a custom delegation tool, custom agent configuration, nested agent
process, telemetry, write-tool blocker, user-message classifier, dependency, or
second routing system. Keep the plugin on native Hermes hooks and
`delegate_task`.
