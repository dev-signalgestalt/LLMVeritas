# LLMVeritas Project Status

**Date:** 2026-04-22  
**Status:** ✅ Source Build Ready → 🚧 Validation & Packaging Next

---

## Current State

The repository is currently a source-first distribution:

- The core YAML spec, templates, and installer are implemented.
- A fresh checkout must run `python3 scripts/build.py` before `./scripts/install.sh`.
- `generated/` remains local build output and is not expected to be committed.
- The current scripts support 7 target agents: Claude Code, Cursor, Codex, OpenCode, Hermes, Gemini CLI, and Pi.

## Implemented

- Core specification in `core/cognitive-system.yml`
- Jinja2 template set for shared and agent-specific outputs
- Build pipeline in `scripts/build.py`
- Universal installer in `scripts/install.sh`
- Adapter documentation under `adapters/`
- Research-backed verification and anti-hallucination system design

## Distribution Reality

Use this workflow from a fresh clone:

```bash
git clone https://github.com/yourusername/llmwatcher.git ~/.llmwatcher
cd ~/.llmwatcher
pip install -r requirements.txt
python3 scripts/build.py
./scripts/install.sh all
```

This repository does not currently provide a standalone bootstrap installer that can succeed without first building local artifacts.

## Next Priorities

1. Add automated tests for generated outputs and installer behavior.
2. Add CI coverage for build and install smoke tests.
3. Run broader manual validation on real agent environments.
4. Package a true bootstrap/distribution path only if it can honestly build or fetch required artifacts.

## Known Constraints

- Pi remains single-layer via `SKILL.md` only.
- Source distribution requires local Python dependencies.
- Agent support claims are documentation-backed, but full cross-environment validation is still in progress.

## Notes

- Remove historical status assumptions when they no longer match the repo.
- Treat this file as an operational snapshot, not a project diary.
