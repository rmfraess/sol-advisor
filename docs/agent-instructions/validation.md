# Validation

## Focused checks

From the repository root, run:

```sh
python -m unittest discover -s tests -p 'test_plugin.py'
sh scripts/verify.sh
git diff --check
```

The stdlib tests cover plugin registration, top-level policy injection,
delegated-child skipping, non-delegation pass-through, exact-route allowance,
and mismatch blocking with all repair commands. The verifier checks the
installable `plugin.yaml` manifest and `__init__.py` entry point, the official
`SKILL.md` frontmatter shape, the bundled skill, focused tests, exact repository
layout, absence of retired routing artifacts, and shell syntax. It does not edit
Hermes configuration or repository files.

## Review discipline

Before acceptance, inspect `git status --short --branch` and the complete diff,
including untracked files. Confirm every changed file is in scope, rerun the
focused tests and verifier from the primary session, and validate every relative
Markdown link against the current tree. Child output alone is not verification.

The repository has no separate build, lint, package-install, or dependency step;
the plugin uses Python stdlib plus Hermes runtime APIs only.
