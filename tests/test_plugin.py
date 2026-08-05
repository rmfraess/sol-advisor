import importlib.util
import unittest
from pathlib import Path
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("sol_advisor_plugin", ROOT / "__init__.py")
PLUGIN = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(PLUGIN)


class FakeContext:
    def __init__(self):
        self.skills = []
        self.hooks = []

    def register_skill(self, name, path, description=""):
        self.skills.append((name, path, description))

    def register_hook(self, name, callback):
        self.hooks.append((name, callback))


class PluginTests(unittest.TestCase):
    def test_registers_qualified_skill_and_hooks(self):
        ctx = FakeContext()

        PLUGIN.register(ctx)

        self.assertEqual([name for name, _ in ctx.hooks], ["pre_llm_call", "pre_tool_call"])
        self.assertEqual(len(ctx.skills), 1)
        name, path, _ = ctx.skills[0]
        self.assertEqual(name, "sol-advisor")
        self.assertEqual(path, ROOT / "skills/software-development/sol-advisor/SKILL.md")
        self.assertTrue(path.is_file())

    def test_injects_policy_for_top_level_turn(self):
        result = PLUGIN.pre_llm_call(parent_session_id="")

        self.assertEqual(result, {"context": PLUGIN.POLICY})
        self.assertIn(
            "skill_view(name='sol-advisor:sol-advisor')", result["context"]
        )
        self.assertIn("delegate_task", result["context"])

    def test_skips_policy_for_delegated_child(self):
        self.assertIsNone(PLUGIN.pre_llm_call(parent_session_id="parent-session"))

    def test_allows_non_delegate_tool_without_reading_config(self):
        with patch.object(PLUGIN, "load_config_readonly") as load_config:
            self.assertIsNone(PLUGIN.pre_tool_call("read_file", {}, "task"))

        load_config.assert_not_called()

    def test_allows_delegate_task_on_exact_route(self):
        config = {
            "delegation": {
                "model": "gpt-5.6-luna",
                "provider": "openai-codex",
                "reasoning_effort": "max",
            }
        }
        with patch.object(PLUGIN, "load_config_readonly", return_value=config):
            self.assertIsNone(PLUGIN.pre_tool_call("delegate_task", {}, "task"))

    def test_blocks_delegate_task_on_route_mismatch_with_repairs(self):
        config = {
            "delegation": {
                "model": "other-model",
                "provider": "other-provider",
                "reasoning_effort": "low",
            }
        }
        with patch.object(PLUGIN, "load_config_readonly", return_value=config):
            result = PLUGIN.pre_tool_call("delegate_task", {}, "task")

        self.assertEqual(result["action"], "block")
        message = result["message"]
        self.assertIn("hermes config set delegation.model gpt-5.6-luna", message)
        self.assertIn("hermes config set delegation.provider openai-codex", message)
        self.assertIn("hermes config set delegation.reasoning_effort max", message)

    def test_blocks_delegate_task_when_config_cannot_be_read(self):
        with patch.object(
            PLUGIN, "load_config_readonly", side_effect=RuntimeError("unavailable")
        ):
            result = PLUGIN.pre_tool_call("delegate_task", {}, "task")

        self.assertEqual(result["action"], "block")
        self.assertIn("hermes config set delegation.model gpt-5.6-luna", result["message"])


if __name__ == "__main__":
    unittest.main()
