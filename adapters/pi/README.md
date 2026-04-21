# Pi (Coding Agent) Adapter

> **Verified Source:** [Pi Coding Agent Documentation](https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent/docs/skills.md)  
> **Standard:** [agentskills.io/specification](https://agentskills.io/specification)  
> **Status:** ✅ Fully Supported (NOT the consumer chatbot pi.ai)

---

## ⚠️ Critical Distinction

There are **two different "Pi" products**:

1. **Pi (consumer chatbot)** — `pi.ai` — Emotional intelligence chatbot by Inflection AI — **NO filesystem skill support**
2. **Pi (coding agent)** — `badlogic/pi-mono` — Terminal-based coding agent — **FULL SKILL.md support**

**This adapter is for #2** — the coding agent from the pi-mono repository.

---

## Verification Evidence

### Source Documentation

From [Pi Coding Agent Skills Documentation](https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent/docs/skills.md) [^1] — verified via browser inspection:

> "Pi implements the **Agent Skills standard**. Each skill is a folder with a `SKILL.md` file. Everything else is freeform."

> "The `SKILL.md` file uses **YAML frontmatter** for metadata and Markdown for content."

### SKILL.md Format Verified

```yaml
---
name: my-skill
description: What this skill does and when to use it. Be specific.
---

# My Skill

## Setup
Run once before first use:
```bash
cd /path/to/skill && npm install
```

## Usage
```bash
./scripts/process.sh <input>
```
```

### Verified Fields (per Agent Skills spec table in docs)

| Field | Required | Rules |
|-------|----------|-------|
| `name` | **Yes** | Max 64 chars. Lowercase a-z, 0-9, hyphens. **Must match parent directory.** |
| `description` | **Yes** | Max 1024 chars. What skill does and when to use it. |
| `license` | No | License name or reference |
| `compatibility` | No | Max 500 chars. Environment requirements. |
| `metadata` | No | Arbitrary key-value mapping |
| `allowed-tools` | No | Space-delimited list of pre-approved tools |
| `disable-model-invocation` | No | When `true`, skill hidden from system prompt |

**Source:** [Pi Skills Documentation](https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent/docs/skills.md) [^1]

---

## Directory Structure

### Standard Layout

```
my-skill/                    # Directory name MUST match 'name' field
├── SKILL.md                 # Required: frontmatter + instructions
├── scripts/                 # Helper scripts
├── references/              # Detailed docs loaded on-demand
└── assets/                  # Additional assets
```

### Discovery Locations (Verified)

From [Pi Skills Documentation](https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent/docs/skills.md) [^1]:

| Location | Path | Priority |
|------------|------|----------|
| **Global** | `~/.pi/agent/skills/` | Standard |
| **Global alt** | `~/.agents/skills/` | Alternative |
| **Project** | `.pi/skills/` | Project-specific |
| **Project alt** | `.agents/skills/` | Alternative |
| **Packages** | `skills/` in package dir | From `package.json` |
| **CLI** | `--skill <path>` flag | Explicit |

**Note:** Pi walks up from cwd to git root, checking each directory for skills.

---

## Installation Path

```bash
# Primary installation directory
~/.pi/agent/skills/llmwatcher/SKILL.md

# Alternative (also valid)
~/.agents/skills/llmwatcher/SKILL.md
```

---

## Special Features

### 1. Name Validation

> "1-64 characters, lowercase letters, numbers, hyphens only. No leading/trailing hyphens. No consecutive hyphens. **Must match parent directory name.**" [^1]

### 2. Validation Behavior

> "Pi validates against the Agent Skills standard (warnings for violations, but remains lenient)"

> **Exception:** "Skills with missing description are **not loaded**"

> "Name collisions (same name from different locations) warn and keep the first skill found"

### 3. Unknown Fields

> "Unknown frontmatter fields are ignored"

### 4. Multiple Sources

Pi loads skills from multiple sources simultaneously:
- Settings file
- Command line flags
- Package directories
- Global directories
- Project directories

---

## LLMWatcher-Specific Adaptation

### Required Fields
```yaml
---
name: llmwatcher
description: Cognitive discipline system for anti-hallucination. Use when agent makes claims without verification, shows overconfidence, or needs confidence calibration.
---

# LLMWatcher

## When to Use
- Agent makes unverified claims
- User requests confidence labels
- Verification failure detected

## Procedure
1. Apply 7-layer verification system
2. Label all claims with confidence markers
3. Run Socratic loop every 60 seconds

## Pitfalls
- Don't proceed without labeling
- Don't justify errors, admit and fix
- Don't assume, verify

## Verification
Check that all output claims have [CONFIRMED], [LIKELY], [UNCERTAIN], [STALE], [VERIFYING], or [SPECULATIVE] labels.
```

### File Placement
```bash
# Create directory (MUST match 'name' field)
mkdir -p ~/.pi/agent/skills/llmwatcher

# Copy skill
cp SKILL.md ~/.pi/agent/skills/llmwatcher/

# Verify directory matches name
ls ~/.pi/agent/skills/llmwatcher/
# Should show: SKILL.md
# Directory name 'llmwatcher' == name field 'llmwatcher' ✓
```

---

## Comparison with Inflection's Pi (Consumer Chatbot)

| Feature | Pi (Coding Agent) | Pi (Consumer Chatbot) |
|---------|-------------------|----------------------|
| **Repository** | badlogic/pi-mono | Inflection AI |
| **Type** | Terminal coding agent | Web/iOS chatbot |
| **SKILL.md** | ✅ Full support | ❌ No filesystem access |
| **YAML frontmatter** | ✅ Supported | ❌ Not applicable |
| **Installation** | `~/.pi/agent/skills/` | N/A (web only) |
| **Use case** | Code generation, editing | Conversational AI |

---

## Verification Checklist

- [x] Agent supports SKILL.md format (verified via github.com/badlogic/pi-mono)
- [x] YAML frontmatter supported (explicitly documented)
- [x] agentskills.io standard compliance (explicitly stated: "Pi implements the Agent Skills standard")
- [x] Directory structure documented (verified)
- [x] Installation paths confirmed (verified: `~/.pi/agent/skills/` and alternatives)
- [x] Name validation rules documented (must match directory name)
- [x] Distinction from Inflection Pi verified (different product, same name)

---

## References

[^1]: Mario Zechner (badlogic), "Skills" in Pi Coding Agent Documentation. https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent/docs/skills.md (Verified via browser inspection: 2026-04-21)
[^2]: Agent Skills Specification. https://agentskills.io/specification
[^3]: Mario Zechner, "Pi Coding Agent README". https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent
