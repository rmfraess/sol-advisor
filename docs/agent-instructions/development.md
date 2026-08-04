# Development

## Layout

- `skills/software-development/sol-advisor/SKILL.md`: shipped Hermes skill.
- `scripts/verify.sh`: the only repository helper; it uses POSIX shell tools.
- `README.md`: installation and user-facing configuration.
- `docs/agent-instructions/`: progressive-disclosure project guidance.

## Toolchain

There is no application runtime, package manifest, dependency install, build,
or compiled artifact. Use a POSIX shell. The focused verifier intentionally
uses `sh`, `find`, `grep`, `awk`, and standard file utilities, so it runs on a
Windows Git Bash host without requiring `python3`.

## Installation

Install the skill from the repository's raw `SKILL.md` URL with
`hermes skills install`, then set the three `delegation.*` keys with
`hermes config set` as shown in [the README](../../README.md).

Do not add a plugin manifest, custom agent configuration, nested agent process,
or a second routing system. Keep the repository to the skill, its verifier, and
its project documentation.
