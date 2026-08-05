"""Native Hermes plugin for the Sol Advisor orchestration policy."""

from pathlib import Path

from hermes_cli.config import cfg_get, load_config_readonly


POLICY = (
    "Sol Advisor policy for this top-level turn:\n"
    "- Before implementation, refactoring, or debugging, call "
    "`skill_view(name='sol-advisor:sol-advisor')`.\n"
    "- Keep design, review, verification, correction, and acceptance in the "
    "primary session.\n"
    "- Route implementation through native `delegate_task`; do not create a "
    "custom delegation path.\n"
    "- Read-only questions and non-code operations are exempt."
)

_ROUTE_BLOCK_MESSAGE = (
    "Sol Advisor blocks `delegate_task` unless Hermes uses the required "
    "GPT-5.6 Luna / openai-codex / max delegation route.\n"
    "Repair with:\n"
    "hermes config set delegation.model gpt-5.6-luna\n"
    "hermes config set delegation.provider openai-codex\n"
    "hermes config set delegation.reasoning_effort max"
)

_REQUIRED_ROUTE = {
    "model": "gpt-5.6-luna",
    "provider": "openai-codex",
    "reasoning_effort": "max",
}

_SKILL_PATH = (
    Path(__file__).resolve().parent
    / "skills"
    / "software-development"
    / "sol-advisor"
    / "SKILL.md"
)


def pre_llm_call(
    session_id="",
    user_message="",
    conversation_history=None,
    is_first_turn=False,
    model="",
    platform="",
    parent_session_id="",
    **kwargs,
):
    """Inject policy for top-level turns and skip delegated children."""
    if parent_session_id:
        return None
    return {"context": POLICY}


def pre_tool_call(tool_name, args, task_id, **kwargs):
    """Fail closed when native delegation is not on the required route."""
    if tool_name != "delegate_task":
        return None

    try:
        config = load_config_readonly()
        route = {
            "model": cfg_get(config, "delegation", "model"),
            "provider": cfg_get(config, "delegation", "provider"),
            "reasoning_effort": cfg_get(
                config, "delegation", "reasoning_effort"
            ),
        }
    except Exception:
        return {"action": "block", "message": _ROUTE_BLOCK_MESSAGE}

    if route == _REQUIRED_ROUTE:
        return None
    return {"action": "block", "message": _ROUTE_BLOCK_MESSAGE}


def register(ctx):
    """Register the bundled skill and the two policy hooks with Hermes."""
    ctx.register_skill(
        "sol-advisor",
        _SKILL_PATH,
        "Keep primary ownership, verification, and acceptance.",
    )
    ctx.register_hook("pre_llm_call", pre_llm_call)
    ctx.register_hook("pre_tool_call", pre_tool_call)
