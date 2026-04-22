# Cursor Adapter

> **Verified Source:** [Cursor Skills Documentation](https://cursor.com/docs/skills)  
> **Standard:** [agentskills.io/specification](https://agentskills.io/specification)  
> **Status:** ✅ Source-ready

---

## Overview

Cursor receives **dual-layer** LLMVeritas coverage:

1. **Global Rules:** `.cursorrules` (always applied)
2. **On-Demand Skill:** `SKILL.md` in `~/.cursor/skills/llmwatcher/` (loaded when needed)

---

## Files Generated

| File | Purpose | Installation |
|------|---------|--------------|
| `.cursorrules` | Global rules | `~/.cursor/.cursorrules` |
| `SKILL.md` | On-demand skill | `~/.cursor/skills/llmwatcher/SKILL.md` |

---

## Setup

```bash
./setup.sh cursor
```

This creates a venv, installs dependencies, builds adapter files, and installs them. No extra steps.

For manual installation, see `scripts/install.sh`.

---

## Usage

### Global Rules

The `.cursorrules` file applies to all projects automatically. Cursor reads it from `~/.cursor/.cursorrules` at startup.

### Skills

The `SKILL.md` is loaded on-demand when the agent detects tasks matching the skill description.

---

## Verification

Check installation:

```bash
ls ~/.cursor/.cursorrules
ls ~/.cursor/skills/llmwatcher/SKILL.md
```

---

## Reference

- [Cursor Skills](https://cursor.com/docs/skills)
- [Agent Skills Specification](https://agentskills.io/specification)
