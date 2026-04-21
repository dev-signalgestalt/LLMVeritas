#!/bin/bash
# LLMWatcher Universal Installer
# Supports: claude-code, cursor, codex, opencode, hermes, gemini-cli, pi (7 agents)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
GENERATED_DIR="$PROJECT_ROOT/generated"

echo "🔧 LLMWatcher Installer"
echo "======================"
echo

# Check arguments
AGENT="${1:-}"

if [ -z "$AGENT" ]; then
    echo "Usage: ./install.sh <agent>"
    echo
    echo "Supported agents:"
    echo "  claude-code    Install for Claude Code"
    echo "  cursor         Install for Cursor"
    echo "  codex          Install for Codex CLI"
    echo "  opencode       Install for OpenCode"
    echo "  hermes         Install for Hermes Agent"
    echo "  gemini-cli     Install for Gemini CLI"
    echo "  pi             Install for Pi Coding Agent"
    echo "  all            Install for all supported agents"
    echo
    echo "Examples:"
    echo "  ./install.sh claude-code"
    echo "  ./install.sh cursor"
    echo "  ./install.sh all"
    exit 1
fi

install_claude_code() {
    echo "📦 Installing for Claude Code..."
    
    SOURCE_DIR="$GENERATED_DIR/claude-code"
    TARGET_DIR="$HOME/.claude"
    
    if [ ! -d "$SOURCE_DIR" ]; then
        echo "   ⚠️  Generated files not found. Run: python3 scripts/build.py"
        return 1
    fi
    
    mkdir -p "$TARGET_DIR/commands"
    
    # Install CLAUDE.md (core global instructions)
    if [ -f "$SOURCE_DIR/CLAUDE.md" ]; then
        cp "$SOURCE_DIR/CLAUDE.md" "$TARGET_DIR/"
        echo "   ✅ Installed: ~/.claude/CLAUDE.md (global instructions)"
    fi
    
    # Install SKILL.md (skill version)
    if [ -f "$SOURCE_DIR/SKILL.md" ]; then
        mkdir -p "$TARGET_DIR/skills/llmwatcher"
        cp "$SOURCE_DIR/SKILL.md" "$TARGET_DIR/skills/llmwatcher/"
        echo "   ✅ Installed: ~/.claude/skills/llmwatcher/SKILL.md"
    fi
    
    # Install commands
    if [ -d "$SOURCE_DIR/commands" ]; then
        cp "$SOURCE_DIR/commands/"*.md "$TARGET_DIR/commands/" 2>/dev/null || true
        echo "   ✅ Installed: ~/.claude/commands/"
    fi
    
    echo "   ✨ Claude Code installation complete!"
    echo "      Restart Claude Code to activate."
}

install_cursor() {
    echo "📦 Installing for Cursor..."
    
    SOURCE_DIR="$GENERATED_DIR/cursor"
    TARGET_DIR="$HOME/.cursor"
    
    if [ ! -d "$SOURCE_DIR" ]; then
        echo "   ⚠️  Generated files not found. Run: python3 scripts/build.py"
        return 1
    fi
    
    mkdir -p "$TARGET_DIR"
    
    # Install .cursorrules (global rules)
    if [ -f "$SOURCE_DIR/.cursorrules" ]; then
        cp "$SOURCE_DIR/.cursorrules" "$TARGET_DIR/"
        echo "   ✅ Installed: ~/.cursor/.cursorrules (global rules)"
    fi
    
    # Install SKILL.md (skill version)
    if [ -f "$SOURCE_DIR/SKILL.md" ]; then
        mkdir -p "$TARGET_DIR/skills/llmwatcher"
        cp "$SOURCE_DIR/SKILL.md" "$TARGET_DIR/skills/llmwatcher/"
        echo "   ✅ Installed: ~/.cursor/skills/llmwatcher/SKILL.md"
    fi
    
    echo "   ✨ Cursor installation complete!"
    echo "      Restart Cursor to activate."
}

install_codex() {
    echo "📦 Installing for Codex CLI..."
    
    SOURCE_DIR="$GENERATED_DIR/codex"
    TARGET_DIR="$HOME/.codex"
    
    if [ ! -d "$SOURCE_DIR" ]; then
        echo "   ⚠️  Generated files not found. Run: python3 scripts/build.py"
        return 1
    fi
    
    mkdir -p "$TARGET_DIR"
    
    # Install AGENTS.md (global instructions)
    if [ -f "$SOURCE_DIR/AGENTS.md" ]; then
        cp "$SOURCE_DIR/AGENTS.md" "$TARGET_DIR/"
        echo "   ✅ Installed: ~/.codex/AGENTS.md (global instructions)"
    fi
    
    # Install SKILL.md (skill version)
    if [ -f "$SOURCE_DIR/SKILL.md" ]; then
        mkdir -p "$TARGET_DIR/skills/llmwatcher"
        cp "$SOURCE_DIR/SKILL.md" "$TARGET_DIR/skills/llmwatcher/"
        echo "   ✅ Installed: ~/.codex/skills/llmwatcher/SKILL.md"
    fi
    
    echo "   ✨ Codex installation complete!"
}

install_opencode() {
    echo "📦 Installing for OpenCode..."
    
    SOURCE_DIR="$GENERATED_DIR/opencode"
    TARGET_DIR="$HOME/.config/opencode"
    
    if [ ! -d "$SOURCE_DIR" ]; then
        echo "   ⚠️  Generated files not found. Run: python3 scripts/build.py"
        return 1
    fi
    
    mkdir -p "$TARGET_DIR"
    
    # Install AGENTS.md (global instructions)
    if [ -f "$SOURCE_DIR/AGENTS.md" ]; then
        cp "$SOURCE_DIR/AGENTS.md" "$TARGET_DIR/"
        echo "   ✅ Installed: ~/.config/opencode/AGENTS.md (global instructions)"
    fi
    
    # Install SKILL.md (skill version)
    if [ -f "$SOURCE_DIR/SKILL.md" ]; then
        mkdir -p "$TARGET_DIR/skills"
        cp "$SOURCE_DIR/SKILL.md" "$TARGET_DIR/skills/llmwatcher.md"
        echo "   ✅ Installed: ~/.config/opencode/skills/llmwatcher.md"
    fi
    
    echo "   ✨ OpenCode installation complete!"
}

install_hermes() {
    echo "📦 Installing for Hermes Agent..."
    
    SOURCE_DIR="$GENERATED_DIR/hermes"
    TARGET_DIR="$HOME/.hermes"
    
    if [ ! -d "$SOURCE_DIR" ]; then
        echo "   ⚠️  Generated files not found. Run: python3 scripts/build.py"
        return 1
    fi
    
    mkdir -p "$TARGET_DIR"
    
    # Install SOUL.md (primary agent identity)
    if [ -f "$SOURCE_DIR/SOUL.md" ]; then
        cp "$SOURCE_DIR/SOUL.md" "$TARGET_DIR/"
        echo "   ✅ Installed: ~/.hermes/SOUL.md (primary identity)"
    fi
    
    # Install SKILL.md (skill version)
    if [ -f "$SOURCE_DIR/SKILL.md" ]; then
        mkdir -p "$TARGET_DIR/skills/llmwatcher"
        cp "$SOURCE_DIR/SKILL.md" "$TARGET_DIR/skills/llmwatcher/"
        echo "   ✅ Installed: ~/.hermes/skills/llmwatcher/SKILL.md"
    fi
    
    echo "   ✨ Hermes installation complete!"
    echo "      SOUL.md sets primary identity, SKILL.md provides detailed protocols."
}

install_gemini_cli() {
    echo "📦 Installing for Gemini CLI..."
    
    SOURCE_DIR="$GENERATED_DIR/gemini-cli"
    TARGET_DIR="$HOME"
    
    if [ ! -d "$SOURCE_DIR" ]; then
        echo "   ⚠️  Generated files not found. Run: python3 scripts/build.py"
        return 1
    fi
    
    # Install GEMINI.md (global context)
    if [ -f "$SOURCE_DIR/GEMINI.md" ]; then
        cp "$SOURCE_DIR/GEMINI.md" "$TARGET_DIR/"
        echo "   ✅ Installed: ~/GEMINI.md (global context)"
    fi
    
    # Install SKILL.md to .gemini/skills/
    if [ -f "$SOURCE_DIR/SKILL.md" ]; then
        mkdir -p "$TARGET_DIR/.gemini/skills/llmwatcher"
        cp "$SOURCE_DIR/SKILL.md" "$TARGET_DIR/.gemini/skills/llmwatcher/"
        echo "   ✅ Installed: ~/.gemini/skills/llmwatcher/SKILL.md"
    fi
    
    # Also install to .agents/skills/ (alternative)
    if [ -f "$SOURCE_DIR/SKILL.md" ]; then
        mkdir -p "$TARGET_DIR/.agents/skills/llmwatcher"
        cp "$SOURCE_DIR/SKILL.md" "$TARGET_DIR/.agents/skills/llmwatcher/"
        echo "   ✅ Installed: ~/.agents/skills/llmwatcher/SKILL.md"
    fi
    
    echo "   ✨ Gemini CLI installation complete!"
    echo "      Run: gemini skills list | grep llmwatcher"
}

install_pi() {
    echo "📦 Installing for Pi Coding Agent..."
    
    SOURCE_DIR="$GENERATED_DIR/pi"
    TARGET_DIR="$HOME/.pi/agent/skills"
    
    if [ ! -d "$SOURCE_DIR" ]; then
        echo "   ⚠️  Generated files not found. Run: python3 scripts/build.py"
        return 1
    fi
    
    mkdir -p "$TARGET_DIR"
    
    # Install SKILL.md to llmwatcher directory
    # IMPORTANT: Directory name MUST match 'name' field in SKILL.md
    if [ -f "$SOURCE_DIR/SKILL.md" ]; then
        mkdir -p "$TARGET_DIR/llmwatcher"
        cp "$SOURCE_DIR/SKILL.md" "$TARGET_DIR/llmwatcher/"
        echo "   ✅ Installed: ~/.pi/agent/skills/llmwatcher/SKILL.md"
    fi
    
    # Also install to .agents/skills/ alternative location
    mkdir -p "$HOME/.agents/skills"
    if [ -f "$SOURCE_DIR/SKILL.md" ]; then
        mkdir -p "$HOME/.agents/skills/llmwatcher"
        cp "$SOURCE_DIR/SKILL.md" "$HOME/.agents/skills/llmwatcher/"
        echo "   ✅ Installed: ~/.agents/skills/llmwatcher/SKILL.md"
    fi
    
    echo "   ✨ Pi installation complete!"
}

# Main installation logic
case "$AGENT" in
    claude-code)
        install_claude_code
        ;;
    cursor)
        install_cursor
        ;;
    codex)
        install_codex
        ;;
    opencode)
        install_opencode
        ;;
    hermes)
        install_hermes
        ;;
    gemini-cli)
        install_gemini_cli
        ;;
    pi)
        install_pi
        ;;
    all)
        echo "🚀 Installing for all 7 agents..."
        echo
        install_claude_code
        echo
        install_cursor
        echo
        install_codex
        echo
        install_opencode
        echo
        install_hermes
        echo
        install_gemini_cli
        echo
        install_pi
        ;;
    *)
        echo "❌ Unknown agent: $AGENT"
        echo "Run ./install.sh for usage."
        exit 1
        ;;
esac

echo
echo "======================"
echo "✅ Installation complete!"
