#!/usr/bin/env python3
"""
LLMVeritas Build Script
Generates platform-specific adapter files from core YAML spec using Jinja2 templates.

Usage:
    python3 scripts/build.py              # Build all adapters
    python3 scripts/build.py --agent cursor  # Build specific adapter

Requirements:
    pip install -r requirements.txt
"""

import os
import sys
import yaml
import argparse
from pathlib import Path

try:
    from jinja2 import Environment, FileSystemLoader, select_autoescape
except ImportError:
    print("❌ Error: jinja2 not installed. Run: pip install jinja2 pyyaml")
    sys.exit(1)

# Configuration
PROJECT_ROOT = Path(__file__).parent.parent
CORE_DIR = PROJECT_ROOT / "core"
TEMPLATES_DIR = PROJECT_ROOT / "templates"
GENERATED_DIR = PROJECT_ROOT / "generated"

# Supported agents
AGENTS = ["claude-code", "cursor", "codex", "opencode", "hermes", "gemini-cli", "pi"]

# Agent skill directories (installation targets)
AGENT_DIRS = {
    "claude-code": "~/.claude/skills/llmwatcher",
    "cursor": "~/.cursor/skills/llmwatcher",
    "codex": "~/.codex/skills/llmwatcher",
    "opencode": "~/.config/opencode/skills",
    "hermes": "~/.hermes/skills/llmwatcher",
    "gemini-cli": "~/.gemini/skills/llmwatcher",
    "pi": "~/.pi/agent/skills/llmwatcher",
}


def load_core_spec():
    """Load the core cognitive system YAML spec."""
    spec_path = CORE_DIR / "cognitive-system.yml"
    if not spec_path.exists():
        print(f"❌ Error: Core spec not found at {spec_path}")
        sys.exit(1)
    
    with open(spec_path, "r") as f:
        return yaml.safe_load(f)


def ensure_directories():
    """Ensure all required directories exist."""
    for agent in AGENTS:
        (GENERATED_DIR / agent).mkdir(parents=True, exist_ok=True)


def get_template_env():
    """Initialize Jinja2 template environment."""
    if not TEMPLATES_DIR.exists():
        print(f"❌ Error: Templates directory not found at {TEMPLATES_DIR}")
        sys.exit(1)
    
    return Environment(
        loader=FileSystemLoader(TEMPLATES_DIR),
        autoescape=select_autoescape(['html', 'xml']),
        trim_blocks=True,
        lstrip_blocks=True
    )


def build_agent(agent, spec, env, verbose=False):
    """Build adapter for a specific agent - SKILL.md and core instruction files."""
    template_name = f"{agent}.j2"
    
    # Build SKILL.md
    try:
        template = env.get_template(template_name)
    except Exception as e:
        if verbose:
            print(f"   ℹ️  Template {template_name} not found, using base.j2")
        try:
            template = env.get_template("base.j2")
        except Exception as e2:
            print(f"   ❌ Error loading base template: {e2}")
            return False
    
    # Render SKILL.md
    context = {
        "agent": agent,
        "name": "llmwatcher",
        "description": "Cognitive discipline system for anti-hallucination and verification. Use when agent makes claims without verification, shows overconfidence, or needs confidence calibration.",
        "version": spec.get("metadata", {}).get("version", "1.0.0"),
        "spec": spec,
    }
    
    # Add agent-specific context
    if agent == "claude-code":
        context["claude_context"] = "fork"
    elif agent == "cursor":
        context["cursor_always_apply"] = "false"
    
    try:
        rendered = template.render(**context)
    except Exception as e:
        print(f"   ❌ Error rendering SKILL.md template: {e}")
        return False
    
    # Write SKILL.md
    output_dir = GENERATED_DIR / agent
    output_dir.mkdir(parents=True, exist_ok=True)
    
    output_path = output_dir / "SKILL.md"
    with open(output_path, "w") as f:
        f.write(rendered)
    
    print(f"   ✅ SKILL.md: {output_path}")
    
    if verbose:
        lines = len(rendered.splitlines())
        print(f"      📊 {lines} lines")
    
    # Build core instruction files per agent
    build_core_files(agent, spec, env, output_dir, verbose)
    
    return True


def build_core_files(agent, spec, env, output_dir, verbose=False):
    """Build core instruction files (CLAUDE.md, AGENTS.md, etc.) per agent."""
    core_files = {
        "claude-code": [
            ("claude-md.j2", "CLAUDE.md"),
        ],
        "cursor": [
            ("cursorrules.j2", ".cursorrules"),
        ],
        "codex": [
            ("agents-md.j2", "AGENTS.md"),
        ],
        "opencode": [
            ("opencode-agents-md.j2", "AGENTS.md"),  # OpenCode has AGENTS.md too!
        ],
        "hermes": [
            ("soul-md.j2", "SOUL.md"),
        ],
        "gemini-cli": [
            ("gemini-md.j2", "GEMINI.md"),
        ],
        "pi": [
            # Pi only supports SKILL.md - no global file
        ],
    }
    
    files_to_build = core_files.get(agent, [])
    
    for template_name, output_name in files_to_build:
        try:
            template = env.get_template(template_name)
            
            context = {
                "agent": agent,
                "name": "llmwatcher",
                "version": spec.get("metadata", {}).get("version", "1.0.0"),
                "spec": spec,
            }
            
            rendered = template.render(**context)
            
            output_path = output_dir / output_name
            with open(output_path, "w") as f:
                f.write(rendered)
            
            print(f"   ✅ {output_name}: {output_path}")
            
            if verbose:
                lines = len(rendered.splitlines())
                print(f"      📊 {lines} lines")
                
        except Exception as e:
            print(f"   ⚠️  {output_name}: {e}")


def build_claude_commands(spec, env, verbose=False):
    """Build Claude Code command files."""
    output_dir = GENERATED_DIR / "claude-code" / "commands"
    output_dir.mkdir(parents=True, exist_ok=True)
    
    commands = [
        ("command-introspect.j2", "introspect.md"),
        ("command-verify.j2", "verify.md"),
    ]
    
    for template_name, output_name in commands:
        try:
            template = env.get_template(template_name)
            rendered = template.render(spec=spec)
            
            output_path = output_dir / output_name
            with open(output_path, "w") as f:
                f.write(rendered)
            
            print(f"   ✅ Command: {output_name}")
            
        except Exception as e:
            print(f"   ⚠️  Command {output_name}: {e}")


def build_all(spec, env, verbose=False):
    """Build all agent adapters."""
    print("🏗️  Building adapters for all 7 agents\n")
    
    results = {}
    for agent in AGENTS:
        print(f"🔨 {agent}...")
        success = build_agent(agent, spec, env, verbose)
        results[agent] = success
        print()
    
    # Build Claude Code commands separately
    print("🔨 claude-code commands...")
    build_claude_commands(spec, env, verbose)
    print()
    
    # Summary
    successful = sum(1 for v in results.values() if v)
    print("=" * 50)
    print(f"✅ Built {successful}/{len(AGENTS)} adapters")
    
    if successful == len(AGENTS):
        print("🎉 All adapters generated successfully!")
    else:
        failed = [k for k, v in results.items() if not v]
        print(f"⚠️  Failed: {', '.join(failed)}")
    
    return results


def print_installation_guide():
    """Print post-build installation guide."""
    print("\n" + "=" * 50)
    print("📦 Installation Guide")
    print("=" * 50)
    print()
    print("To install for a specific agent:")
    print("  ./scripts/install.sh <agent>")
    print()
    print("To install for all agents:")
    print("  ./scripts/install.sh all")
    print()
    print("Generated files location:")
    print(f"  {GENERATED_DIR}/")
    print()
    print("Installation targets:")
    print()
    print("Core Instruction Files (Global):")
    print("  claude-code  → ~/.claude/CLAUDE.md + commands/")
    print("  cursor       → ~/.cursor/.cursorrules")
    print("  codex        → ~/.codex/AGENTS.md")
    print("  opencode     → ~/.config/opencode/AGENTS.md")
    print("  hermes       → ~/.hermes/SOUL.md")
    print("  gemini-cli   → ~/GEMINI.md")
    print()
    print("Skill Files (On-Demand):")
    print("  claude-code  → ~/.claude/skills/llmwatcher/SKILL.md")
    print("  cursor       → ~/.cursor/skills/llmwatcher/SKILL.md")
    print("  codex        → ~/.codex/skills/llmwatcher/SKILL.md")
    print("  opencode     → ~/.config/opencode/skills/llmwatcher.md")
    print("  hermes       → ~/.hermes/skills/llmwatcher/SKILL.md")
    print("  gemini-cli   → ~/.gemini/skills/llmwatcher/SKILL.md")
    print("  pi           → ~/.pi/agent/skills/llmwatcher/SKILL.md")


def main():
    parser = argparse.ArgumentParser(
        description="Build LLMVeritas adapter files from core spec",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 scripts/build.py              # Build all adapters
  python3 scripts/build.py --agent hermes  # Build only Hermes
  python3 scripts/build.py --verbose    # Verbose output
        """
    )
    parser.add_argument(
        "--agent",
        choices=AGENTS + ["all"],
        default="all",
        help="Build specific agent adapter (default: all)"
    )
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Verbose output with line counts"
    )
    
    args = parser.parse_args()
    
    print("🔧 LLMVeritas Build System")
    print("=" * 50)
    print()
    
    # Load core spec
    print("📂 Loading core specification...")
    spec = load_core_spec()
    version = spec.get("metadata", {}).get("version", "unknown")
    print(f"   Core spec loaded: v{version}")
    print()
    
    # Ensure directories
    ensure_directories()
    
    # Initialize template environment
    env = get_template_env()
    print(f"🎨 Templates loaded from: {TEMPLATES_DIR}")
    print()
    
    # Build requested adapters
    if args.agent == "all":
        build_all(spec, env, args.verbose)
    else:
        print(f"🔨 Building {args.agent}...")
        success = build_agent(args.agent, spec, env, args.verbose)
        print()
        if success:
            print(f"✅ {args.agent} adapter generated successfully")
        else:
            print(f"❌ {args.agent} adapter generation failed")
            sys.exit(1)
    
    # Print installation guide
    print_installation_guide()
    
    print()
    print("Next steps:")
    print("  1. Review generated files in generated/")
    print("  2. Run ./scripts/install.sh <agent> to install")
    print("  3. Or manually copy files to agent directories")


if __name__ == "__main__":
    main()
