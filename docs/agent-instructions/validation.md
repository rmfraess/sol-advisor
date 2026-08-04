# Validation

## Focused check

From the repository root, run:

```sh
sh scripts/verify.sh
git diff --check
```

The verifier checks the official `SKILL.md` frontmatter shape, required native
routing and task-packet text, the exact repository layout, absence of retired
routing artifacts, and shell syntax. It does not edit Hermes configuration or
repository files and cleans up nothing because it creates no temporary state.

## Review discipline

Before acceptance, inspect `git status --short --branch` and the complete diff,
including untracked files. Confirm every changed file is in scope, rerun the
focused verifier from the primary session, and validate every relative Markdown
link against the current tree. Child output alone is not verification.

The repository has no separate build, lint, test, or package-install step.
