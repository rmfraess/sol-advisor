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

Keep the current primary session responsible for requirements, architecture,
file ownership, task packets, monitoring, actual diff inspection, correction,
verification, and final acceptance. Route bounded implementation through native
Hermes `delegate_task` using the globally configured GPT-5.6 Luna / Max child
lane.

## When to use

Use this skill for implementation, refactoring, debugging, or other repository
work where a stronger primary session should direct a fresh-context worker.
Use it from that primary session; it does not change the primary model. Do not
substitute an app-task API, nested CLI or agent process, custom-agent file, new
routing system, custom tool, or durable background job.

## Required routing configuration

Before the first delegation, resolve all three values with Hermes:

```sh
hermes config get delegation.model
hermes config get delegation.provider
hermes config get delegation.reasoning_effort
```

Require exactly:

```text
delegation.model = gpt-5.6-luna
delegation.provider = openai-codex
delegation.reasoning_effort = max
```

If a value differs or cannot be resolved, stop and tell the user to run:

```sh
hermes config set delegation.model gpt-5.6-luna
hermes config set delegation.provider openai-codex
hermes config set delegation.reasoning_effort max
```

Do not hand-edit Hermes configuration. `delegate_task` has no per-call model,
provider, or reasoning selector; the global delegation keys own this routing.

## Primary workflow

1. **Frame the work.** Resolve material ambiguity, settle the architecture,
   identify the repository root and base, choose exact owned files, and define
   the narrowest verification that proves the requested behavior.
2. **Write the packet.** Fill every section in the packet below. A child starts
   with no parent conversation, so replace every placeholder with observed facts.
3. **Delegate once per bounded unit.** Call native `delegate_task` with the
   packet in `goal` and `context`. Do not pass model, provider, or reasoning
   fields. Batch only independent packets with non-overlapping ownership;
   serialize shared-file and dependent work.
4. **Receive and inspect.** Top-level delegation is asynchronous; the result
   re-enters this parent conversation automatically. It is process-local and
   is not durable execution. Do not invent wait/read task APIs. Treat the
   report as a claim, then inspect the actual working tree, status, complete
   diff, changed-file scope, and requested artifacts in the primary session.
5. **Verify.** Rerun every packet command in the primary session and compare its
   concrete output with the objective, interfaces, and constraints. Do not
   accept a report without this inspection.
6. **Correct precisely.** If anything is wrong, send a new `delegate_task` call
   with the exact finding, owned files, required correction, and rerun checks.
   A completed leaf child is not interactive or resumable; never rely on an
   invented follow-up handle. Reinspect and reverify after every correction.
7. **Accept.** Report completion only when the actual diff is in scope, all
   required checks pass, and the evidence supports the objective. Keep commits
   and pushes outside the child unless the primary explicitly requests them.

### Native delegation shape

Use the native tool with only its supported task context:

```text
delegate_task(
  goal="Implement the task packet exactly and return its structured report.",
  context="""
  <complete packet from the next section>
  """
)
```

## Complete task packet

Every child receives all of the following sections. Do not send a partial prompt
and do not assume the child can infer the parent's state.

```text
ROLE
Act as Sol Advisor's implementation worker. Execute this packet within the
settled architecture. Preserve stated interfaces and constraints, surface
ambiguity, and do not broaden ownership.

OBJECTIVE
<Observable outcome, why it matters, and acceptance condition.>

FILES AND OWNERSHIP
You own only:
- <Exact repository-relative files or directories.>
You do not own:
- <Explicitly excluded paths and parent-owned work.>
Preserve edits already present and adapt to concurrent changes. Do not modify
files outside this ownership; return a blocker instead.

INTERFACES
- <Signatures, schemas, commands, routes, or behavior that must remain compatible.>

CONSTRAINTS
- <Repository conventions, safety boundaries, settled decisions, and excluded scope.>
- Use the configured Hermes delegation lane; do not introduce another one.
- Do not commit or push unless the packet explicitly authorizes it.

STARTING STATE / BASE
- Repository root: <exact path>
- Branch and base: <exact observed branch/ref>
- Existing status: <exact `git status --short --branch` result>
- Prior accepted change, if any: <exact commit/ref or none>

VERIFICATION
- Run: <exact focused command>
  Success: <concrete expected output or exit status>
- Run: <exact broader command, if required>
  Success: <concrete expected output or exit status>
- Inspect: <exact files, diff, or runtime evidence>
  Success: <concrete evidence required for acceptance>

GIT / ACCEPTANCE BOUNDARY
- Report status, base, changed files, complete diff, and commit state.
- Do not alter another stack or claim that process isolation makes shared edits
  merge-safe.
- The primary session owns correction, acceptance, and any later publication.

STRUCTURED RETURN
STATUS: complete | partial | blocked
OBJECTIVE: <one-line restatement>
CHANGES: <file-by-file summary from the actual diff>
VERIFIED: <exact commands plus concrete evidence>
JUDGMENT CALLS: <decisions left open, or none>
GAPS: <unfinished work, blockers, or none>
```

## Failure and acceptance rules

- A missing, mismatched, or unavailable delegation configuration stops the lane;
  do not silently fall back to another model, provider, or routing mechanism.
- Independent batches are optional, not a requirement. Fewer serial delegations
  are preferable when ownership or ordering is unclear.
- A child may report success while leaving an incorrect or out-of-scope diff;
  the primary's inspection and rerun checks are the acceptance gate.
- If the parent process ends while a child is running, the child is not a
  durable job. Re-establish the task explicitly rather than assuming resume.

## Verification checklist

- [ ] The three `delegation.*` values resolve to the required contract.
- [ ] The child packet contains every required section and observed base state.
- [ ] Ownership is non-overlapping for any concurrent batch.
- [ ] The primary inspected status, complete diff, and changed-file scope.
- [ ] The primary reran the packet's checks after the final correction.
- [ ] The returned structured report matches observed evidence.
