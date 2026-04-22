# Codex CLI Adapter

> **Verified Source:** [Codex AGENTS.md Documentation](https://developers.openai.com/codex/guides/agents-md)  
> **Standard:** [agentskills.io/specification](https://agentskills.io/specification)  
> **Status:** ✅ Source-ready

---

## Overview

Codex CLI receives **dual-layer** LLMVeritas coverage:

1. **Global Instructions:** `AGENTS.md` (always loaded)
2. **On-Demand Skill:** `SKILL.md` in `~/.codex/skills/llmwatcher/` (loaded when needed)

---

## Files Generated

| File | Purpose | Installation |
|------|---------|--------------|
| `AGENTS.md` | Global instructions | `~/.codex/AGENTS.md` |
| `SKILL.md` | On-demand skill | `~/.codex/skills/llmwatcher/SKILL.md` |

---

## Installation

```bash
./scripts/install.sh codex
```

Or manually:

```bash
# Global instructions
cp generated/codex/AGENTS.md ~/.codex/

# Skill
mkdir -p ~/.codex/skills/llmwatcher
cp generated/codex/SKILL.md ~/.codex/skills/llmwatcher/
```

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
ls ~/.codex/skills/llmwatcher/SKILL.md
```

---

## Reference

- [Codex AGENTS.md Guide](https://developers.openai.com/codex/guides/agents-md)
- [Agent Skills Specification](https://agentskills.io/specification)
