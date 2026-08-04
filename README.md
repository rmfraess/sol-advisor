# Sol Advisor

Sol Advisor is a native Hermes Agent skill for keeping architecture, delegated
implementation, verification, and acceptance in the primary session. It routes
bounded implementation through Hermes `delegate_task` using the globally
configured GPT-5.6 Luna / Max child lane.

## Install

Install the skill directly from this repository:

```sh
hermes skills install \
  https://raw.githubusercontent.com/rmfraess/sol-advisor/main/skills/software-development/sol-advisor/SKILL.md \
  --category software-development \
  --name sol-advisor
```

The skill needs no plugin manifest, custom agent file, companion installer, or
new dependency.

## Required delegation configuration

Set the child lane through Hermes configuration commands; do not hand-edit
`config.yaml`:

```sh
hermes config set delegation.model gpt-5.6-luna
hermes config set delegation.provider openai-codex
hermes config set delegation.reasoning_effort max
```

The skill checks these resolved values before it delegates. `delegate_task`
does not select a model per call, so these global keys are the routing contract.

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

## Local verification

From the repository root:

```sh
sh scripts/verify.sh
git diff --check
```

The focused verifier uses POSIX shell utilities, works from Git Bash on Windows,
and fails on missing skill structure or stale legacy routing artifacts.

## Repository layout

- `skills/software-development/sol-advisor/SKILL.md` — the shipped Hermes skill.
- `scripts/verify.sh` — the narrow repository structure and routing verifier.
- `AGENTS.md` — progressive-disclosure project instructions.
- `docs/agent-instructions/` — development, orchestration, and validation details.

## License

MIT
