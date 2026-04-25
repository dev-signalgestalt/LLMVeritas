#!/bin/bash
# LLMVeritas Universal Installer
# Supports: claude-code, cursor, codex, opencode, hermes, gemini-cli, pi (7 agents)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
GENERATED_DIR="$PROJECT_ROOT/generated"

warn_overwrite() {
    local target="$1"
    if [ -f "$target" ]; then
        echo "   ⚠️  Overwriting existing: $target"
    fi
}

require_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "   ❌ Missing expected generated file: $file"
        echo "      Run: python3 scripts/build.py"
        return 1
    fi
}

echo "🔧 LLMVeritas Installer"
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
    
    mkdir -p "$TARGET_DIR/commands" || return 1
    
    # Install CLAUDE.md (core global instructions)
    require_file "$SOURCE_DIR/CLAUDE.md" || return 1
    warn_overwrite "$TARGET_DIR/CLAUDE.md"
    cp "$SOURCE_DIR/CLAUDE.md" "$TARGET_DIR/" || return 1
    echo "   ✅ Installed: ~/.claude/CLAUDE.md (global instructions)"
    
    # Install SKILL.md (skill version)
    require_file "$SOURCE_DIR/SKILL.md" || return 1
    mkdir -p "$TARGET_DIR/skills/llmveritas" || return 1
    warn_overwrite "$TARGET_DIR/skills/llmveritas/SKILL.md"
    cp "$SOURCE_DIR/SKILL.md" "$TARGET_DIR/skills/llmveritas/" || return 1
    echo "   ✅ Installed: ~/.claude/skills/llmveritas/SKILL.md"
    
    # Install commands
    require_file "$SOURCE_DIR/commands/introspect.md" || return 1
    require_file "$SOURCE_DIR/commands/verify.md" || return 1
    for cmd_file in "$SOURCE_DIR/commands/"*.md; do
        [ -f "$cmd_file" ] || continue
        warn_overwrite "$TARGET_DIR/commands/$(basename "$cmd_file")"
    done
    cp "$SOURCE_DIR/commands/"*.md "$TARGET_DIR/commands/" || return 1
    echo "   ✅ Installed: ~/.claude/commands/"
    
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
    
    mkdir -p "$TARGET_DIR" || return 1
    
    # Install .cursorrules (legacy global rules — works in Chat/Composer, NOT in Agent mode)
    require_file "$SOURCE_DIR/.cursorrules" || return 1
    warn_overwrite "$TARGET_DIR/.cursorrules"
    cp "$SOURCE_DIR/.cursorrules" "$TARGET_DIR/" || return 1
    echo "   ✅ Installed: ~/.cursor/.cursorrules (legacy global rules)"
    
    # Install SKILL.md (skill version)
    require_file "$SOURCE_DIR/SKILL.md" || return 1
    mkdir -p "$TARGET_DIR/skills/llmveritas" || return 1
    warn_overwrite "$TARGET_DIR/skills/llmveritas/SKILL.md"
    cp "$SOURCE_DIR/SKILL.md" "$TARGET_DIR/skills/llmveritas/" || return 1
    echo "   ✅ Installed: ~/.cursor/skills/llmveritas/SKILL.md"
    
    require_file "$SOURCE_DIR/llmveritas.mdc" || return 1
    
    echo "   ✨ Cursor installation complete!"
    echo "      .cursorrules → Chat/Composer mode"
    echo "      For Agent mode, copy generated/cursor/llmveritas.mdc to your project's .cursor/rules/"
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
    
    mkdir -p "$TARGET_DIR" || return 1
    
    # Install AGENTS.md (global instructions)
    require_file "$SOURCE_DIR/AGENTS.md" || return 1
    warn_overwrite "$TARGET_DIR/AGENTS.md"
    cp "$SOURCE_DIR/AGENTS.md" "$TARGET_DIR/" || return 1
    echo "   ✅ Installed: ~/.codex/AGENTS.md (global instructions)"
    
    # Install SKILL.md to ~/.agents/skills/ (primary — per official Codex docs)
    require_file "$SOURCE_DIR/SKILL.md" || return 1
    mkdir -p "$HOME/.agents/skills/llmveritas" || return 1
    warn_overwrite "$HOME/.agents/skills/llmveritas/SKILL.md"
    cp "$SOURCE_DIR/SKILL.md" "$HOME/.agents/skills/llmveritas/" || return 1
    echo "   ✅ Installed: ~/.agents/skills/llmveritas/SKILL.md (primary)"

    # Also install to ~/.codex/skills/ (forward compatibility)
    mkdir -p "$TARGET_DIR/skills/llmveritas" || return 1
    warn_overwrite "$TARGET_DIR/skills/llmveritas/SKILL.md"
    cp "$SOURCE_DIR/SKILL.md" "$TARGET_DIR/skills/llmveritas/" || return 1
    echo "   ✅ Installed: ~/.codex/skills/llmveritas/SKILL.md (forward compat)"
    
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
    
    mkdir -p "$TARGET_DIR" || return 1
    
    # Install AGENTS.md (global instructions)
    require_file "$SOURCE_DIR/AGENTS.md" || return 1
    warn_overwrite "$TARGET_DIR/AGENTS.md"
    cp "$SOURCE_DIR/AGENTS.md" "$TARGET_DIR/" || return 1
    echo "   ✅ Installed: ~/.config/opencode/AGENTS.md (global instructions)"
    
    # Install SKILL.md (skill version)
    require_file "$SOURCE_DIR/SKILL.md" || return 1
    mkdir -p "$TARGET_DIR/skills" || return 1
    warn_overwrite "$TARGET_DIR/skills/llmveritas.md"
    cp "$SOURCE_DIR/SKILL.md" "$TARGET_DIR/skills/llmveritas.md" || return 1
    echo "   ✅ Installed: ~/.config/opencode/skills/llmveritas.md"
    
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
    
    mkdir -p "$TARGET_DIR" || return 1
    
    # Install SOUL.md (primary agent identity)
    require_file "$SOURCE_DIR/SOUL.md" || return 1
    warn_overwrite "$TARGET_DIR/SOUL.md"
    cp "$SOURCE_DIR/SOUL.md" "$TARGET_DIR/" || return 1
    echo "   ✅ Installed: ~/.hermes/SOUL.md (primary identity)"
    
    # Install SKILL.md (skill version)
    require_file "$SOURCE_DIR/SKILL.md" || return 1
    mkdir -p "$TARGET_DIR/skills/llmveritas" || return 1
    warn_overwrite "$TARGET_DIR/skills/llmveritas/SKILL.md"
    cp "$SOURCE_DIR/SKILL.md" "$TARGET_DIR/skills/llmveritas/" || return 1
    echo "   ✅ Installed: ~/.hermes/skills/llmveritas/SKILL.md"
    
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
    require_file "$SOURCE_DIR/GEMINI.md" || return 1
    warn_overwrite "$TARGET_DIR/GEMINI.md"
    cp "$SOURCE_DIR/GEMINI.md" "$TARGET_DIR/" || return 1
    echo "   ✅ Installed: ~/GEMINI.md (global context)"
    
    # Install SKILL.md to .gemini/skills/
    require_file "$SOURCE_DIR/SKILL.md" || return 1
    mkdir -p "$TARGET_DIR/.gemini/skills/llmveritas" || return 1
    warn_overwrite "$TARGET_DIR/.gemini/skills/llmveritas/SKILL.md"
    cp "$SOURCE_DIR/SKILL.md" "$TARGET_DIR/.gemini/skills/llmveritas/" || return 1
    echo "   ✅ Installed: ~/.gemini/skills/llmveritas/SKILL.md"
    
    echo "   ✨ Gemini CLI installation complete!"
    echo "      Run: gemini skills list | grep llmveritas"
}

install_pi() {
    echo "📦 Installing for Pi Coding Agent..."
    
    SOURCE_DIR="$GENERATED_DIR/pi"
    TARGET_DIR="$HOME/.pi/agent/skills"
    
    if [ ! -d "$SOURCE_DIR" ]; then
        echo "   ⚠️  Generated files not found. Run: python3 scripts/build.py"
        return 1
    fi
    
    mkdir -p "$TARGET_DIR" || return 1
    
    # Install SKILL.md to llmveritas directory
    # IMPORTANT: Directory name MUST match 'name' field in SKILL.md
    require_file "$SOURCE_DIR/SKILL.md" || return 1
    mkdir -p "$TARGET_DIR/llmveritas" || return 1
    warn_overwrite "$TARGET_DIR/llmveritas/SKILL.md"
    cp "$SOURCE_DIR/SKILL.md" "$TARGET_DIR/llmveritas/" || return 1
    echo "   ✅ Installed: ~/.pi/agent/skills/llmveritas/SKILL.md"
    
    echo "   ✨ Pi installation complete!"
}

run_install() {
    local agent_name="$1"
    local install_fn="$2"

    if "$install_fn"; then
        INSTALL_SUCCESSES+=("$agent_name")
    else
        INSTALL_FAILURES+=("$agent_name")
    fi
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
        INSTALL_SUCCESSES=()
        INSTALL_FAILURES=()

        echo "🚀 Installing for all 7 agents..."
        echo
        run_install "claude-code" install_claude_code
        echo
        run_install "cursor" install_cursor
        echo
        run_install "codex" install_codex
        echo
        run_install "opencode" install_opencode
        echo
        run_install "hermes" install_hermes
        echo
        run_install "gemini-cli" install_gemini_cli
        echo
        run_install "pi" install_pi
        ;;
    *)
        echo "❌ Unknown agent: $AGENT"
        echo "Run ./install.sh for usage."
        exit 1
        ;;
esac

echo
echo "======================"

if [ "$AGENT" = "all" ]; then
    if [ ${#INSTALL_FAILURES[@]} -eq 0 ]; then
        echo "✅ Installation complete!"
        echo "Installed agents: ${INSTALL_SUCCESSES[*]}"
    else
        if [ ${#INSTALL_SUCCESSES[@]} -gt 0 ]; then
            echo "⚠️  Installation partially complete."
            echo "Installed agents: ${INSTALL_SUCCESSES[*]}"
        else
            echo "❌ Installation failed."
        fi
        echo "Failed agents: ${INSTALL_FAILURES[*]}"
        exit 1
    fi
else
    echo "✅ Installation complete!"
fi
