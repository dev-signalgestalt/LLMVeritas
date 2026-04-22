# OpenCode Adapter

> **Verified Source:** [OpenCode Skills Documentation](https://opencode.ai/docs/skills)  
> **Standard:** [agentskills.io/specification](https://agentskills.io/specification)  
> **Status:** ✅ Source-ready

---

## Overview

OpenCode receives **dual-layer** LLMVeritas coverage:

1. **Global Instructions:** `AGENTS.md` in `~/.config/opencode/` (always loaded)
2. **On-Demand Skill:** `SKILL.md` in `~/.config/opencode/skills/` (loaded when needed)

---

## Files Generated

| File | Purpose | Installation |
|------|---------|--------------|
| `AGENTS.md` | Global instructions | `~/.config/opencode/AGENTS.md` |
| `SKILL.md` | On-demand skill | `~/.config/opencode/skills/llmwatcher.md` |

---

## Setup

```bash
./setup.sh opencode
```

This creates a venv, installs dependencies, builds adapter files, and installs them. No extra steps.

For manual installation, see `scripts/install.sh`.

---

## Usage

### Skill Discovery

OpenCode natively discovers skills from:
- `~/.config/opencode/skills/`
- `.opencode/skills/`
- `.claude/skills/` (shared with Claude Code)
- `.agents/skills/` (shared agent directory)

---

## Verification

Check installation:

```bash
ls ~/.config/opencode/AGENTS.md
ls ~/.config/opencode/skills/llmwatcher.md
```

---

## Reference

- [OpenCode Skills](https://opencode.ai/docs/skills)
- [Agent Skills Specification](https://agentskills.io/specification)
