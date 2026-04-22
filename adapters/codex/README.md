# Codex CLI Adapter

> **Verified Source:** [Codex AGENTS.md Documentation](https://developers.openai.com/codex/guides/agents-md)  
> **Standard:** [agentskills.io/specification](https://agentskills.io/specification)  
> **Status:** ✅ Source-ready

---

## Overview

Codex CLI receives **dual-layer** LLMVeritas coverage:

1. **Global Instructions:** `AGENTS.md` (always loaded)
2. **On-Demand Skill:** `SKILL.md` in `~/.codex/skills/llmveritas/` (loaded when needed)

---

## Files Generated

| File | Purpose | Installation |
|------|---------|--------------|
| `AGENTS.md` | Global instructions | `~/.codex/AGENTS.md` |
| `SKILL.md` | On-demand skill | `~/.codex/skills/llmveritas/SKILL.md` |

---

## Setup

```bash
./setup.sh codex
```

This creates a venv, installs dependencies, builds adapter files, and installs them. No extra steps.

For manual installation, see `scripts/install.sh`.

---

## Usage

### Global Instructions

Codex reads `AGENTS.md` from `~/.codex/` automatically. These apply to all projects.

### Skills

Codex discovers skills from:
- `~/.codex/skills/<name>/SKILL.md`
- `.codex/skills/<name>/SKILL.md` (project-local)

---

## Verification

Check installation:

```bash
ls ~/.codex/AGENTS.md
ls ~/.codex/skills/llmveritas/SKILL.md
```

---

## Reference

- [Codex AGENTS.md Guide](https://developers.openai.com/codex/guides/agents-md)
- [Agent Skills Specification](https://agentskills.io/specification)
