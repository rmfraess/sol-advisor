#!/bin/sh
# Focused structure check for the native Hermes skill.

set -eu

pass() { printf '%s\n' "PASS: $*"; }
fail() { printf '%s\n' "FAIL: $*" >&2; exit 1; }

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd) || exit 1
repo_dir=$(CDPATH= cd "$script_dir/.." && pwd) || exit 1
skill_dir=$repo_dir/skills/software-development/sol-advisor
skill=$skill_dir/SKILL.md
readme=$repo_dir/README.md
agents=$repo_dir/AGENTS.md

[ -f "$skill" ] || fail "skill is missing: $skill"
[ -f "$readme" ] || fail "README is missing"
[ -f "$agents" ] || fail "AGENTS.md is missing"
[ -f "$repo_dir/docs/agent-instructions/development.md" ] || fail "development guidance is missing"
[ -f "$repo_dir/docs/agent-instructions/orchestration.md" ] || fail "orchestration guidance is missing"
[ -f "$repo_dir/docs/agent-instructions/validation.md" ] || fail "validation guidance is missing"

[ "$(find "$skill_dir" -mindepth 1 -type f -name '*.md' -print | wc -l | tr -d ' ')" = 1 ] ||
  fail "skill directory must contain exactly one Markdown file"
[ ! -e "$repo_dir/.agents" ] || fail "retired marketplace directory remains"
[ ! -e "$repo_dir/plugins" ] || fail "retired plugin directory remains"

stale_files=$(find "$repo_dir" -path "$repo_dir/.git" -prune -o -type f \( -name '*.toml' -o -name 'plugin.json' \) -print)
[ -z "$stale_files" ] || fail "retired routing files remain: $stale_files"

# Keep the shipped skill in the official frontmatter shape without requiring YAML.
awk '
  NR == 1 && $0 != "---" { exit 1 }
  NR > 1 && $0 == "---" { found = 1; exit }
  END { if (!found) exit 1 }
' "$skill" || fail "SKILL.md frontmatter is missing or malformed"

for required in \
  'delegate_task' \
  'delegation.model' \
  'delegation.provider' \
  'delegation.reasoning_effort' \
  'gpt-5.6-luna' \
  'openai-codex' \
  'reasoning_effort max' \
  'OBJECTIVE' \
  'FILES AND OWNERSHIP' \
  'INTERFACES' \
  'CONSTRAINTS' \
  'STARTING STATE / BASE' \
  'VERIFICATION' \
  'STRUCTURED RETURN'; do
  grep -Fq "$required" "$skill" || fail "skill omits required contract text: $required"
done
pass "skill frontmatter, routing contract, and task packet"

for document in "$readme" "$agents" "$repo_dir/docs/agent-instructions/development.md" \
  "$repo_dir/docs/agent-instructions/orchestration.md" "$repo_dir/docs/agent-instructions/validation.md" "$skill"; do
  if grep -Eiq 'spawn_agent|create_thread|list_projects|custom-agent.*TOML|\.codex-plugin' "$document"; then
    fail "retired routing language remains in $document"
  fi
done
pass "retired routing language is absent"

sh -n "$script_dir/verify.sh"
pass "shell syntax"
printf '%s\n' "VERIFY PASSED: native Hermes skill structure is valid"
