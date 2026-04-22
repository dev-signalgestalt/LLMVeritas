# LLMVeritas Project Status

**Date:** 2026-04-22  
**Status:** ✅ Source Build Ready + Repo-Based Updates Implemented

---

## Current State

The repository is currently a source-first distribution:

- The core YAML spec, templates, and installer are implemented.
- A fresh checkout installs with `./setup.sh <agent>`.
- Existing installs update with `./update.sh [agent|all]`.
- `generated/` remains local build output and is not expected to be committed.
- The current scripts support 7 target agents: Claude Code, Cursor, Codex, OpenCode, Hermes, Gemini CLI, and Pi.
- Installed targets are tracked in `~/.llmveritas/install-state.json`.
- Replaced files are backed up under `~/.llmveritas/backups/`.

## Implemented

- Core specification in `core/cognitive-system.yml`
- Jinja2 template set for shared and agent-specific outputs
- Build pipeline in `scripts/build.py`
- Universal installer in `scripts/install.sh`
- Repo-based updater in `update.sh`
- Install-state and backup helper in `scripts/install_state.py`
- Adapter documentation under `adapters/`
- Research-backed verification and anti-hallucination system design

## Distribution Reality

Use this workflow from a fresh clone:

```bash
git clone https://github.com/dev-signalgestalt/LLMVeritas.git ~/.llmveritas
cd ~/.llmveritas
./setup.sh all
```

Use this workflow later on the same machine:

```bash
cd ~/.llmveritas
./update.sh
```

This repository still does not provide a standalone bootstrap installer outside the repo clone; updates are intentionally managed from the local checkout.

## Next Priorities

1. Add automated tests for generated outputs and installer behavior.
2. Add CI coverage for build and install smoke tests.
3. Run broader manual validation on real agent environments.
4. Package a true bootstrap/distribution path only if it can honestly build or fetch required artifacts.

## Known Constraints

- Pi remains single-layer via `SKILL.md` only.
- Source distribution requires local Python dependencies.
- `./update.sh` expects a git checkout and uses `git pull --ff-only`.
- Agent support claims are documentation-backed, but full cross-environment validation is still in progress.

## Notes

- Remove historical status assumptions when they no longer match the repo.
- Treat this file as an operational snapshot, not a project diary.
