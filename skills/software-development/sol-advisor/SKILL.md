---
name: sol-advisor
description: "Use when Hermes delegate_task routes implementation. Keep primary ownership, verification, and acceptance."
version: 1.0.0
author: Ronald Fraess
license: MIT
platforms: [windows, macos, linux]
metadata:
  hermes:
    tags: [orchestration, delegation, implementation, verification]
    related_skills: []
---

# Sol Advisor

Use for implementation, refactoring, or debugging; read-only/non-code work is
exempt. Primary owns requirements, architecture, packet, diff review,
verification, correction, acceptance, and commits/pushes; a fresh Luna child
owns bounded implementation.

## Gate

Required route:

```text
delegation.model = gpt-5.6-luna
delegation.provider = openai-codex
delegation.reasoning_effort = max
```

The plugin's `pre_tool_call` enforces it, including `reasoning_effort max`.
Blocked delegation requires config repair; no fallback. Calls inherit the route
and have no per-call model/provider/reasoning fields.

## Workflow

1. **Frame.** Resolve ambiguity, settle architecture, observe root/branch/base/status,
   choose ownership, and define checks.
   **Done when:** scope, interfaces, base, ownership, and checks are concrete.
2. **Packet.** Complete fields below with observed facts; replace placeholders.
   **Done when:** a fresh child can execute without parent context.
3. **Delegate.** Call native `delegate_task(goal=..., context=<packet>)` only.
   Parallelize independent/non-overlapping packets; serialize dependent/shared
   files. Results return to primary; delegation is process-local/non-durable.
   **Done when:** a complete packet is dispatched on the gated route.
4. **Inspect/verify.** Treat the report as a claim. In primary inspect status,
   full diff, scope, and artifacts; rerun every packet check. **Done when:**
   evidence proves objective, interfaces, constraints, and scope.
5. **Correct/accept.** On failure, send new precise `delegate_task` with finding,
   owned files, fix, and checks; never resume a completed leaf. Reinspect/
   reverify. Accept only in-scope diff with passing checks/evidence; primary
   owns publication.

## Packet

Copy this packet into the child's `context`:

```text
ROLE
Fresh-context Luna worker. Implement only this packet; preserve
interfaces/constraints, surface ambiguity, and return the structured report.

OBJECTIVE
<Observable outcome, why it matters, and success criteria.>

FILES AND OWNERSHIP
You own only:
- <Exact repository-relative files or directories.>
You do not own:
- <Exact excluded paths and primary-owned work.>
Preserve existing/concurrent edits; report scope conflicts as blockers.

INTERFACES
- <Signatures, schemas, commands, routes, or compatible behavior>

CONSTRAINTS
- <Conventions, decisions, safety boundaries, excluded scope>
- Configured Hermes lane; no alternate path.
- Commit/push only if this packet authorizes it.

STARTING STATE / BASE
- Repository root: <Exact path>
- Branch/base: <Exact branch and base ref>
- Status: <Exact git status --short --branch result>

VERIFICATION
- Run: <Focused command>; success: <Exit status or output>
- Run: <Broader command if required>; success: <Exit status or output>
- Inspect: <Files, diff, or runtime evidence>; success: <Acceptance evidence>

STRUCTURED RETURN
STATUS: complete | partial | blocked
CHANGES: <Actual diff, file by file>
VERIFIED: <Commands and concrete evidence>
JUDGMENT CALLS: <Open decisions, or none>
GAPS: <Work, blockers, or none>
```
