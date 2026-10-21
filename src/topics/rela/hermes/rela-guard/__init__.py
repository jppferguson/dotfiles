"""Rela guard for Hermes: veto tool calls in a checkout whose .context/policy.yaml denies Hermes.

A shell wrapper cannot catch Hermes because it runs as a daemon, so this plugin asks personal-os's rela-guard
(apps/rela/dist/guard.js) on every pre_tool_call, passing the vendor of the model Hermes is configured with
(``unknown`` when it cannot be told, which the guard denies wherever any vendor is denied). It checks the terminal
working directory and any path the tool names. It stops accidents, not a determined bypass.
"""

from __future__ import annotations

import os
import shutil
import subprocess
from pathlib import Path
from typing import Any, Optional

GUARD_JS = Path(
    os.environ.get("RELA_GUARD_JS", Path.home() / "Development/Personal/personal-os/apps/rela/dist/guard.js")
)
PATH_ARGS = ("path", "file_path", "workdir", "cwd")
GUARD_TIMEOUT_SECONDS = 10

# Hermes provider ids and model-name prefixes to the vendor slugs of @personal-os/shared's AI_VENDORS.
PROVIDER_VENDORS = {
    "openai": "openai",
    "openai-codex": "openai",
    "codex": "openai",
    "anthropic": "anthropic",
    "claude": "anthropic",
    "nous": "nous",
    "xai": "xai",
    "grok": "xai",
    "copilot": "github",
    "github-copilot": "github",
}
MODEL_VENDORS = {
    "gpt-": "openai",
    "o1": "openai",
    "o3": "openai",
    "o4": "openai",
    "codex": "openai",
    "openai/": "openai",
    "claude": "anthropic",
    "anthropic/": "anthropic",
    "hermes": "nous",
    "nousresearch/": "nous",
    "grok": "xai",
    "x-ai/": "xai",
}


def configured_vendor(config: Any) -> str:
    """The vendor of Hermes's configured model, or "unknown" when the config does not settle it."""
    model = config.get("model") if isinstance(config, dict) else None
    if not isinstance(model, dict):
        return "unknown"
    provider = str(model.get("provider") or "").lower()
    if provider in PROVIDER_VENDORS:
        return PROVIDER_VENDORS[provider]
    name = str(model.get("default") or "").lower()
    for prefix, vendor in MODEL_VENDORS.items():
        if name.startswith(prefix):
            return vendor
    return "unknown"


def _load_vendor() -> str:
    hermes_home = Path(os.environ.get("HERMES_HOME", Path.home() / ".hermes"))
    try:
        import yaml

        return configured_vendor(yaml.safe_load((hermes_home / "config.yaml").read_text()))
    except Exception:
        return "unknown"


def _find_policy(target: str) -> Optional[Path]:
    path = Path(target)
    while not path.is_dir() and path != path.parent:
        path = path.parent
    for directory in (path, *path.parents):
        candidate = directory / ".context" / "policy.yaml"
        if candidate.is_file():
            return candidate
    return None


def _node() -> Optional[str]:
    explicit = os.environ.get("RELA_GUARD_NODE")
    if explicit:
        return explicit
    # A launchd daemon's PATH often lacks asdf, so fall back to its shims explicitly.
    return shutil.which("node") or shutil.which("node", path=str(Path.home() / ".asdf/shims"))


def check(cwd: str, paths: list[str], vendor: str) -> Optional[str]:
    """None to allow, or the reason to block."""
    node = _node()
    status = "not installed"
    if GUARD_JS.is_file() and node:
        args = [node, str(GUARD_JS), "--tool", "hermes", "--vendor", vendor, "--cwd", cwd]
        for target in paths:
            args += ["--path", target]
        try:
            run = subprocess.run(
                args, cwd=GUARD_JS.parent, capture_output=True, text=True, timeout=GUARD_TIMEOUT_SECONDS
            )
            if run.returncode == 0:
                return None
            if run.returncode == 1:
                return run.stderr.strip()
            status = f"exit {run.returncode}"
        except (OSError, subprocess.TimeoutExpired) as error:
            status = type(error).__name__

    # The guard could not answer: fail closed only where a policy applies.
    for target in [cwd, *paths]:
        policy = _find_policy(os.path.join(cwd, target))
        if policy:
            return (
                f"rela guard: hermes is denied: {policy} applies here but {GUARD_JS} did not run ({status}), "
                "so failing closed"
            )
    return None


def pre_tool_call(tool_name: str = "", args: Optional[dict] = None, **_: Any) -> Optional[dict]:
    args = args if isinstance(args, dict) else {}
    cwd = os.environ.get("TERMINAL_CWD") or os.getcwd()
    paths = [value for key in PATH_ARGS if isinstance(value := args.get(key), str) and value]
    reason = check(cwd, paths, _load_vendor())
    return {"action": "block", "message": reason} if reason else None


def register(ctx: Any) -> None:
    ctx.register_hook("pre_tool_call", pre_tool_call)
