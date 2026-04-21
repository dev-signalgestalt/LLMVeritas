# Claude Code Adapter

> **Verified Source:** [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)  
> **Standard:** [agentskills.io/specification](https://agentskills.io/specification)  
> **Status:** ✅ Fully Supported

---

## Overview

Claude Code receives **dual-layer** LLMVeritas coverage:

1. **Global Instructions:** `CLAUDE.md` (always loaded) + `/commands/` (introspect, verify)
2. **On-Demand Skill:** `SKILL.md` in `~/.claude/skills/llmwatcher/` (loaded when needed)

---

## Files Generated

| File | Purpose | Installation |
|------|---------|--------------|
| `CLAUDE.md` | Global instructions | `~/.claude/CLAUDE.md` |
| `SKILL.md` | On-demand skill | `~/.claude/skills/llmwatcher/SKILL.md` |
| `commands/introspect.md` | /introspect command | `~/.claude/commands/introspect.md` |
| `commands/verify.md` | /verify command | `~/.claude/commands/verify.md` |

---

## Installation

```bash
./scripts/install.sh claude-code
```

Or manually:

```bash
# Global instructions
cp generated/claude-code/CLAUDE.md ~/.claude/

# Commands
mkdir -p ~/.claude/commands
cp generated/claude-code/commands/*.md ~/.claude/commands/

# Skill
mkdir -p ~/.claude/skills/llmwatcher
cp generated/claude-code/SKILL.md ~/.claude/skills/llmwatcher/
```

---

## Usage

### Commands

Use these anytime to force verification:

- `/introspect` — Run full 7-layer verification
- `/verify` — Check all current assumptions

### Automatic Triggers

Claude Code applies LLMVeritas automatically when:
- User says "introspect", "verify", "check yourself"
- Agent detects overconfidence
- Error patterns detected

---

## Verification

Check installation:

```bash
ls ~/.claude/CLAUDE.md
ls ~/.claude/commands/introspect.md
ls ~/.claude/skills/llmwatcher/SKILL.md
```

---

## Reference

- [Claude Code Skills](https://code.claude.com/docs/en/skills)
- [Agent Skills Specification](https://agentskills.io/specification)
