# Orchestration

Read the [Sol Advisor skill](../../skills/software-development/sol-advisor/SKILL.md)
before changing delegation behavior. It is the single source of truth.

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
new precise delegation for corrections. Top-level delegation returns its result
into the parent conversation and is process-local, so do not invent wait/read
APIs or durable-job semantics.
