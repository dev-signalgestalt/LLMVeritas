# Gemini CLI Adapter

> **Verified Source:** [Gemini CLI Skills Documentation](https://geminicli.com/docs/cli/skills/)  
> **Standard:** [agentskills.io/specification](https://agentskills.io/specification)  
> **Status:** ✅ Source-ready

---

## Verification Evidence

### Source Documentation

From [Gemini CLI Agent Skills](https://geminicli.com/docs/cli/skills/) [^1]:

> "Agent Skills allow you to extend Gemini CLI with specialized expertise, procedural workflows, and task-specific resources. Based on the **Agent Skills open standard**, a 'skill' is a self-contained directory that packages instructions and assets into a discoverable capability."

From [Creating Agent Skills](https://geminicli.com/docs/cli/creating-skills/) [^2]:

> "The `SKILL.md` file is the core of your skill. This file uses **YAML frontmatter for metadata and Markdown for instructions**."

### SKILL.md Format Verified

```yaml
---
name: code-reviewer
description: Use this skill to review code. It supports both local changes and remote Pull Requests.
---

# Code Reviewer

This skill guides the agent in conducting thorough code reviews.

## Workflow

### 1. Determine Review Target
- **Remote PR**: If the user gives a PR number or URL, target that remote PR.
- **Local Changes**: If changes are local...
```

**Verified Fields:**
- `name` (required) — "A unique identifier for the skill. This should match the directory name." [^2]
- `description` (required) — "A description of what the skill does and when Gemini should use it." [^2]

**Optional Fields (per agentskills.io):**
- `license`
- `compatibility`
- `metadata`

---

## Directory Structure

### Standard Layout

```
my-skill/
├── SKILL.md       (Required) Instructions and metadata
├── scripts/       (Optional) Executable scripts
├── references/    (Optional) Static documentation
└── assets/        (Optional) Templates and other resources
```

**Source:** [Gemini CLI Skill Structure](https://geminicli.com/docs/cli/creating-skills/) [^2]

### Discovery Tiers

From [Gemini CLI Skills Discovery](https://geminicli.com/docs/cli/skills/) [^1]:

> Gemini CLI scans skills from these locations (in order):

| Scope | Path | Use Case |
|-------|------|----------|
| **Project** | `.gemini/skills/` | Project-specific skills |
| **Project** | `.agents/skills/` | Shared agent skills directory |
| **User** | `~/.gemini/skills/` | Personal skills across projects |

> **Note:** `~/.agents/skills/` is supported at project scope (`.agents/skills/`) but is not a user-level discovery path for Gemini CLI per official docs — only `~/.gemini/skills/` is. This differs from Codex, where `~/.agents/skills/` is the primary user-level path.

---

## Setup

```bash
./setup.sh gemini-cli
```

This creates a venv, installs dependencies, builds adapter files, and installs them. No extra steps.

For manual installation, see `scripts/install.sh`.

---

## Installation Paths

```bash
# User-scoped (available in all projects)
~/.gemini/skills/llmveritas/SKILL.md

# Project-scoped (specific to project)
./.gemini/skills/llmveritas/SKILL.md
```

---

## Special Features

### 1. Skill Activation Flow

From [Gemini CLI Skills Documentation](https://geminicli.com/docs/cli/skills/) [^1]:

> "**Discovery**: At the start of a session, Gemini CLI scans the discovery tiers and injects the name and description of all enabled skills into the system prompt."

> "**Activation**: When Gemini identifies a task matching a skill's description, it calls the `activate_skill` tool."

> "**Consent**: You will see a confirmation prompt in the UI detailing the skill's name, purpose, and the directory path it will gain access to."

> "**Injection**: Upon your approval: The `SKILL.md` body and folder structure is added to the conversation history."

### 2. CLI Commands

```bash
# List all discovered skills
gemini skills list

# Link skills from local directory (creates symlinks)
gemini skills link /path/to/my-skills-repo
gemini skills link /path/to/my-skills-repo --scope workspace

# Install from Git repository
gemini skills install https://github.com/user/repo.git
gemini skills install /path/to/local/skill

# Install to workspace scope
gemini skills install https://github.com/user/repo.git --scope workspace
```

### 3. Comparison with GEMINI.md

From [Beyond Prompt Engineering](https://medium.com/google-cloud/beyond-prompt-engineering-using-agent-skills-in-gemini-cli-04d9af3cda21) [^3]:

> "You might be wondering, 'I spent the better part of 2025 crafting the perfect `GEMINI.md` file for my project. Why do I need skills?'"

> "In many cases though, any attempt to craft a perfect context file meant it quickly became bloated, hard to manage which hurts both performance and accuracy."

> "Skills are essentially just a folder that contains a markdown file called `SKILL.md` that follows the **Agent Skill Schema**."

---

## LLMVeritas-Specific Adaptation

### Required Fields
```yaml
---
name: llmveritas
description: Cognitive discipline system for anti-hallucination. Use when agent shows signs of overconfidence, verification failure, or needs confidence calibration.
---

# LLMVeritas

## When to Use
- Agent makes claims without verification
- Agent shows overconfidence in uncertain situations
- User requests verification or introspection

## Procedure
1. Apply confidence labels ([CONFIRMED], [LIKELY], [UNCERTAIN], etc.)
2. Run verification gates (Pre-thought, Mid-process, Post-output)
3. Execute Socratic loop questions

## Verification
Confirm all claims have confidence labels before proceeding.
```

### File Placement
```bash
# Global installation
mkdir -p ~/.gemini/skills/llmveritas
cp SKILL.md ~/.gemini/skills/llmveritas/

# Verify installation
gemini skills list | grep llmveritas
```

---

## Verification Checklist

- [x] Agent supports SKILL.md format (verified via geminicli.com)
- [x] YAML frontmatter supported (explicitly documented)
- [x] agentskills.io standard compliance (explicitly stated: "Based on the Agent Skills open standard")
- [x] Directory structure documented (verified)
- [x] Installation paths confirmed (verified: `~/.gemini/skills/` and `.gemini/skills/`)
- [x] Activation mechanism documented (discovery → activation → consent → injection)
- [x] CLI commands verified (gemini skills list, link, install)

---

## References

[^1]: Google, "Agent Skills" in Gemini CLI Documentation. https://geminicli.com/docs/cli/skills/
[^2]: Google, "Creating Agent Skills" in Gemini CLI Documentation. https://geminicli.com/docs/cli/creating-skills/
[^3]: Daniel Strebel, "Beyond Prompt Engineering: Using Agent Skills in Gemini CLI", Google Cloud Community, Medium, Feb 2026. https://medium.com/google-cloud/beyond-prompt-engineering-using-agent-skills-in-gemini-cli-04d9af3cda21
[^4]: Agent Skills Specification. https://agentskills.io/specification
