# Hermes Adapter

> **Verified Source:** [Hermes Agent Skills Documentation](https://hermes-agent.nousresearch.com/docs/user-guide/features/skills)  
> **Standard:** [agentskills.io/specification](https://agentskills.io/specification)  
> **Status:** ✅ Fully Supported

---

## Verification Evidence

### Source Documentation

From [Hermes Agent Skills System](https://hermes-agent.nousresearch.com/docs/user-guide/features/skills) [^1]:

> "Skills are on-demand knowledge documents the agent can load when needed. They follow a **progressive disclosure** pattern to minimize token usage and are **compatible with the agentskills.io open standard**."

> "All skills live in **`~/.hermes/skills/`** — the primary directory and source of truth."

### SKILL.md Format Verified

```yaml
---
name: my-skill
description: Brief description of what this skill does
version: 1.0.0
platforms: [macos, linux]  # Optional — restrict to specific OS platforms
metadata:
  hermes:
    tags: [python, automation]
    category: devops
    fallback_for_toolsets: [web]      # Conditional activation
    requires_toolsets: [terminal]       # Conditional activation
    config:                           # Config.yaml settings
      - key: my.setting
        description: "What this controls"
        default: "value"
        prompt: "Prompt for setup"
---

# Skill Title

## When to Use
Trigger conditions for this skill.

## Procedure
1. Step one
2. Step two

## Pitfalls
- Known failure modes and fixes

## Verification
How to confirm it worked.
```

**Verified Fields:**
- `name` (required, max 64 chars, lowercase alphanumeric + hyphens)
- `description` (required, max 1024 chars)
- `version` (optional)
- `platforms` (optional — OS restriction)
- `metadata.hermes` (optional — Hermes-specific settings)

---

## Directory Structure

```
~/.hermes/skills/                  # Single source of truth
├── mlops/                         # Category directory
│   ├── axolotl/
│   │   ├── SKILL.md               # Main instructions (required)
│   │   ├── references/            # Additional docs
│   │   ├── templates/             # Output formats
│   │   ├── scripts/               # Helper scripts callable from skill
│   │   └── assets/                # Supplementary files
│   └── vllm/
├── devops/
│   └── deploy-k8s/                # Agent-created skill
│       ├── SKILL.md
│       └── references/
├── .hub/                          # Skills Hub state
└── .bundled_manifest              # Tracks seeded bundled skills
```

**Source:** [Hermes Skills System Directory Structure](https://hermes-agent.nousresearch.com/docs/user-guide/features/skills) [^1]

---

## Installation Path

```bash
# Primary installation directory
~/.hermes/skills/llmwatcher/SKILL.md

# Category subdirectory (optional but recommended)
~/.hermes/skills/productivity/llmwatcher/SKILL.md
```

---

## Special Features

### 1. Progressive Disclosure
> "At startup, agents load only the skill name and description from the YAML frontmatter. Full Markdown instructions and associated resources load only when a skill activates, minimizing token usage across large registries." [^1]

### 2. Hermes-Specific Metadata
Hermes extends the standard with `metadata.hermes`:
- `tags`: Skill categorization
- `category`: Grouping for skill hub
- `fallback_for_toolsets`: Conditional activation when primary tools fail
- `requires_toolsets`: Required tools for skill activation
- `config`: Automatic `config.yaml` integration

### 3. Skill Hub Integration
```bash
hermes skills search kubernetes
hermes skills install openai/skills/k8s
hermes skills list
```

---

## LLMVeritas-Specific Adaptation

### Required Fields
```yaml
---
name: llmwatcher
description: Cognitive discipline system for anti-hallucination and verification. Use when agent makes claims without verification, shows overconfidence, or needs confidence calibration.
version: 1.0.0
metadata:
  hermes:
    tags: [verification, truth, discipline]
    category: core
---
```

### File Placement
```bash
# Option 1: Global (available in all projects)
~/.hermes/skills/llmwatcher/SKILL.md

# Option 2: Categorized
~/.hermes/skills/core/llmwatcher/SKILL.md
```

---

## Verification Checklist

- [x] Agent supports SKILL.md format (verified via hermes-agent.nousresearch.com)
- [x] YAML frontmatter supported (verified)
- [x] agentskills.io standard compliance (explicitly stated)
- [x] Directory structure documented (verified)
- [x] Installation path confirmed (verified: `~/.hermes/skills/`)
- [x] Special features identified (progressive disclosure, hermes-specific metadata)

---

## References

[^1]: Nous Research, "Skills System" in Hermes Agent User Guide. https://hermes-agent.nousresearch.com/docs/user-guide/features/skills
[^2]: Agent Skills Specification. https://agentskills.io/specification
[^3]: Nous Research, "Working with Skills" in Hermes Agent Guides. https://hermes-agent.nousresearch.com/docs/guides/work-with-skills
