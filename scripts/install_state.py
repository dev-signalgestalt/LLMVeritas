#!/usr/bin/env python3
"""
Track LLMVeritas install state and backup installed files before replacement.
"""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

STATE_ROOT = Path.home() / ".llmveritas"
STATE_PATH = STATE_ROOT / "install-state.json"
BACKUPS_ROOT = STATE_ROOT / "backups"
AGENT_ORDER = [
    "claude-code",
    "cursor",
    "codex",
    "opencode",
    "hermes",
    "gemini-cli",
    "pi",
]


def now_utc() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def default_state() -> dict:
    return {
        "installed_agents": [],
        "repo_path": None,
        "spec_version": None,
        "last_install_at": None,
        "last_commit": None,
        "agent_installs": {},
    }


def load_state() -> dict:
    if not STATE_PATH.exists():
        return default_state()
    try:
        with STATE_PATH.open("r", encoding="utf-8") as handle:
            data = json.load(handle)
    except (json.JSONDecodeError, OSError):
        return default_state()
    merged = default_state()
    merged.update(data)
    merged["agent_installs"] = data.get("agent_installs", {})
    return merged


def save_state(state: dict) -> None:
    STATE_ROOT.mkdir(parents=True, exist_ok=True)
    with STATE_PATH.open("w", encoding="utf-8") as handle:
        json.dump(state, handle, indent=2, sort_keys=True)
        handle.write("\n")


def git_commit(repo_path: Path) -> str | None:
    try:
        result = subprocess.run(
            ["git", "-C", str(repo_path), "rev-parse", "HEAD"],
            check=True,
            capture_output=True,
            text=True,
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None
    return result.stdout.strip() or None


def sort_agents(agents: list[str]) -> list[str]:
    order = {agent: index for index, agent in enumerate(AGENT_ORDER)}
    return sorted(set(agents), key=lambda agent: order.get(agent, len(order)))


def record_install(agent: str, repo_path: str, spec_version: str | None) -> None:
    repo = Path(repo_path).expanduser().resolve()
    state = load_state()
    installed_agents = list(state.get("installed_agents", []))
    installed_agents.append(agent)

    timestamp = now_utc()
    state["installed_agents"] = sort_agents(installed_agents)
    state["repo_path"] = str(repo)
    state["spec_version"] = spec_version
    state["last_install_at"] = timestamp
    state["last_commit"] = git_commit(repo)
    state["agent_installs"][agent] = {
        "installed_at": timestamp,
        "repo_path": str(repo),
        "spec_version": spec_version,
        "commit": state["last_commit"],
    }
    save_state(state)


def list_installed() -> int:
    state = load_state()
    agents = state.get("installed_agents", [])
    if not agents:
        return 1
    for agent in agents:
        print(agent)
    return 0


def print_repo_path() -> int:
    state = load_state()
    repo_path = state.get("repo_path")
    if not repo_path:
        return 1
    print(repo_path)
    return 0


def create_backup_session() -> None:
    BACKUPS_ROOT.mkdir(parents=True, exist_ok=True)
    session_dir = BACKUPS_ROOT / datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    suffix = 1
    while session_dir.exists():
        session_dir = BACKUPS_ROOT / f"{datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')}-{suffix}"
        suffix += 1
    session_dir.mkdir(parents=True, exist_ok=False)
    print(session_dir)


def relative_backup_path(target: Path) -> Path:
    home = Path.home().resolve()
    resolved = target.expanduser().resolve()
    try:
        return resolved.relative_to(home)
    except ValueError:
        parts = [part for part in resolved.parts if part not in (resolved.anchor, "/")]
        return Path("_absolute").joinpath(*parts)


def backup_file(target: str, session_dir: str) -> int:
    target_path = Path(target).expanduser()
    if not target_path.exists():
        return 0

    destination_root = Path(session_dir).expanduser().resolve()
    destination = destination_root / relative_backup_path(target_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(target_path, destination)
    print(destination)
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="LLMVeritas install-state helper")
    subparsers = parser.add_subparsers(dest="command", required=True)

    record_parser = subparsers.add_parser("record-install")
    record_parser.add_argument("--agent", required=True)
    record_parser.add_argument("--repo-path", required=True)
    record_parser.add_argument("--spec-version")

    subparsers.add_parser("list-installed")
    subparsers.add_parser("repo-path")
    subparsers.add_parser("create-backup-session")

    backup_parser = subparsers.add_parser("backup-file")
    backup_parser.add_argument("--target", required=True)
    backup_parser.add_argument("--session-dir", required=True)

    args = parser.parse_args()

    if args.command == "record-install":
        record_install(args.agent, args.repo_path, args.spec_version)
        return 0
    if args.command == "list-installed":
        return list_installed()
    if args.command == "repo-path":
        return print_repo_path()
    if args.command == "create-backup-session":
        create_backup_session()
        return 0
    if args.command == "backup-file":
        return backup_file(args.target, args.session_dir)
    return 1


if __name__ == "__main__":
    sys.exit(main())
