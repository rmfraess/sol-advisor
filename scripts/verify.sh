#!/bin/sh
# Focused structure and behavior check for the native Hermes plugin.

set -eu

pass() { printf '%s\n' "PASS: $*"; }
fail() { printf '%s\n' "FAIL: $*" >&2; exit 1; }

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd) || exit 1
repo_dir=$(CDPATH= cd "$script_dir/.." && pwd) || exit 1
skill_dir=$repo_dir/skills/software-development/sol-advisor
skill=$skill_dir/SKILL.md
manifest=$repo_dir/plugin.yaml
entrypoint=$repo_dir/__init__.py
test_file=$repo_dir/tests/test_plugin.py
readme=$repo_dir/README.md
agents=$repo_dir/AGENTS.md
hermes_context=$repo_dir/.hermes.md

[ -f "$manifest" ] || fail "plugin manifest is missing: $manifest"
[ -f "$entrypoint" ] || fail "plugin entry point is missing: $entrypoint"
[ -f "$test_file" ] || fail "plugin tests are missing: $test_file"
[ -f "$skill" ] || fail "bundled skill is missing: $skill"
[ -f "$readme" ] || fail "README is missing"
[ -f "$agents" ] || fail "AGENTS.md is missing"
[ -f "$hermes_context" ] || fail ".hermes.md bootstrap is missing"
[ -f "$repo_dir/docs/agent-instructions/development.md" ] || fail "development guidance is missing"
[ -f "$repo_dir/docs/agent-instructions/orchestration.md" ] || fail "orchestration guidance is missing"
[ -f "$repo_dir/docs/agent-instructions/validation.md" ] || fail "validation guidance is missing"

[ "$(find "$skill_dir" -mindepth 1 -type f -name '*.md' -print | wc -l | tr -d ' ')" = 1 ] ||
  fail "skill directory must contain exactly one Markdown file"
[ ! -e "$repo_dir/.agents" ] || fail "retired marketplace directory remains"
[ ! -e "$repo_dir/plugins" ] || fail "retired plugin directory remains"

stale_files=$(find "$repo_dir" -path "$repo_dir/.git" -prune -o -type f \( -name '*.toml' -o -name 'plugin.json' \) -print)
[ -z "$stale_files" ] || fail "retired routing files remain: $stale_files"

for required in \
  'name: sol-advisor' \
  'provides_hooks:' \
  '  - pre_llm_call' \
  '  - pre_tool_call' \
  'provides_skills:' \
  '  - sol-advisor'; do
  grep -Fq "$required" "$manifest" || fail "manifest omits required plugin contract: $required"
done
pass "plugin manifest hooks and bundled skill"

for required in \
  'def register' \
  'register_skill' \
  'sol-advisor' \
  'register_hook("pre_llm_call"' \
  'register_hook("pre_tool_call"' \
  'parent_session_id' \
  'load_config_readonly' \
  'cfg_get' \
  'delegate_task' \
  'gpt-5.6-luna' \
  'openai-codex' \
  'reasoning_effort'; do
  grep -Fq "$required" "$entrypoint" || fail "entry point omits required behavior: $required"
done
pass "plugin entry point and route gate"

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
pass "bundled skill frontmatter, routing contract, and task packet"

grep -Fq 'AGENTS.md' "$hermes_context" || fail ".hermes.md does not load project guidance"
grep -Fq 'sol-advisor:sol-advisor' "$hermes_context" || fail ".hermes.md does not require the qualified skill"
pass "Hermes session bootstrap"

for document in "$readme" "$agents" "$repo_dir/docs/agent-instructions/development.md" \
  "$repo_dir/docs/agent-instructions/orchestration.md" "$repo_dir/docs/agent-instructions/validation.md" \
  "$hermes_context" "$skill"; do
  if grep -Eiq 'spawn_agent|create_thread|list_projects|custom-agent.*TOML|\.codex-plugin|no plugin manifest|Do not add a plugin manifest|skill-only' "$document"; then
    fail "retired routing language remains in $document"
  fi
done
pass "retired routing language is absent"

if command -v python >/dev/null 2>&1; then
  python_bin=python
elif command -v python3 >/dev/null 2>&1; then
  python_bin=python3
else
  fail "Python is required to run the focused stdlib plugin tests"
fi

(
  CDPATH= cd "$repo_dir" &&
    "$python_bin" -m unittest discover -s tests -p 'test_plugin.py'
) || fail "focused plugin tests failed"
pass "focused stdlib plugin tests"

sh -n "$script_dir/verify.sh"
pass "shell syntax"
printf '%s\n' "VERIFY PASSED: native Hermes plugin structure and behavior are valid"
