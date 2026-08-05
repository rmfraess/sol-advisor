# Orchestration

Read the [Sol Advisor skill](../../skills/software-development/sol-advisor/SKILL.md)
before changing delegation behavior. The installable plugin bundles that skill
and is the global enforcement seam.

## Plugin activation and policy

Install the repository plugin with `hermes plugins install` and restart Hermes
so the startup loader sees `plugin.yaml` and `__init__.py`. The plugin registers
the skill under `sol-advisor:sol-advisor`.

- `pre_llm_call` returns the Sol Advisor policy for every top-level turn.
- It returns `None` for delegated children when Hermes supplies a non-empty
  `parent_session_id`; it does not infer child status from model names or global
  process state.
- The policy requires the qualified skill before implementation, refactoring, or
  debugging, keeps design/review/verification/acceptance in the primary, and
  routes implementation through native `delegate_task`.
- `pre_tool_call` only gates `delegate_task`. It reads the resolved config and
  allows exactly `gpt-5.6-luna` / `openai-codex` / `max`; every other tool passes
  through and mismatches return Hermes' block directive with repair commands.

## Routing contract

- Check `delegation.model` = `gpt-5.6-luna`.
- Check `delegation.provider` = `openai-codex`.
- Check `delegation.reasoning_effort` = `max`.
- Set mismatches with `hermes config set`; do not override routing in a child call.

## Primary ownership

The primary session resolves requirements and architecture, assigns exact file
ownership, writes the complete task packet, inspects the actual diff, reruns
verification, decides corrections, and accepts the result.

Children start with fresh context. Their packet must include the objective,
owned and excluded files, interfaces, constraints, repository/base state,
verification commands and success criteria, and a structured return. Treat a
child report as a claim until the primary confirms it against the working tree.

Batch only independent, non-overlapping work. Serialize shared-file and
dependent work. A completed leaf child is not interactive or resumable; send a
new precise delegation packet for corrections. Top-level delegation returns its
result into the parent conversation and is process-local, so do not invent
wait/read APIs or durable-job semantics.
