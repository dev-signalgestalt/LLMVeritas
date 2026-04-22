#!/bin/bash
# LLMVeritas Universal Installer
# Supports: claude-code, cursor, codex, opencode, hermes, gemini-cli, pi (7 agents)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
GENERATED_DIR="$PROJECT_ROOT/generated"
STATE_HELPER="$PROJECT_ROOT/scripts/install_state.py"
SPEC_VERSION="$(awk '/^  version:/{print $2; exit}' "$PROJECT_ROOT/core/cognitive-system.yml" 2>/dev/null || true)"
PYTHON_BIN="$PROJECT_ROOT/.venv/bin/python3"

if [ ! -x "$PYTHON_BIN" ]; then
    PYTHON_BIN="${PYTHON:-python3}"
fi

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

ensure_state_helper() {
    if [ ! -f "$STATE_HELPER" ]; then
        echo "❌ Missing install-state helper: $STATE_HELPER"
        exit 1
    fi
}

backup_session_dir() {
    if [ -n "${LLMVERITAS_BACKUP_SESSION_DIR:-}" ]; then
        echo "$LLMVERITAS_BACKUP_SESSION_DIR"
        return 0
    fi

    LLMVERITAS_BACKUP_SESSION_DIR="$("$PYTHON_BIN" "$STATE_HELPER" create-backup-session)"
    export LLMVERITAS_BACKUP_SESSION_DIR
    echo "$LLMVERITAS_BACKUP_SESSION_DIR"
}

backup_if_needed() {
    local target_path="$1"

    if [ ! -f "$target_path" ]; then
        return 0
    fi

    local source_path="$2"
    if [ -n "$source_path" ] && cmp -s "$source_path" "$target_path"; then
        return 0
    fi

    local session_dir
    session_dir="$(backup_session_dir)"
    local backup_path
    backup_path="$("$PYTHON_BIN" "$STATE_HELPER" backup-file --target "$target_path" --session-dir "$session_dir")"
    if [ -n "$backup_path" ]; then
        echo "   🗂️  Backed up: $target_path -> $backup_path"
    fi
}

install_file() {
    local source_path="$1"
    local target_path="$2"
    local label="$3"

    if [ ! -f "$source_path" ]; then
        return 0
    fi

    mkdir -p "$(dirname "$target_path")" || return 1
    backup_if_needed "$target_path" "$source_path"
    cp "$source_path" "$target_path" || return 1
    echo "   ✅ Installed: $label"
}

record_agent_install() {
    local agent_name="$1"
    "$PYTHON_BIN" "$STATE_HELPER" record-install \
        --agent "$agent_name" \
        --repo-path "$PROJECT_ROOT" \
        --spec-version "${SPEC_VERSION:-unknown}" || return 1
}

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
    if [ -f "$SOURCE_DIR/CLAUDE.md" ]; then
        install_file "$SOURCE_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md" "~/.claude/CLAUDE.md (global instructions)" || return 1
    fi
    
    # Install SKILL.md (skill version)
    if [ -f "$SOURCE_DIR/SKILL.md" ]; then
        install_file "$SOURCE_DIR/SKILL.md" "$TARGET_DIR/skills/llmveritas/SKILL.md" "~/.claude/skills/llmveritas/SKILL.md" || return 1
    fi
    
    # Install commands
    if [ -d "$SOURCE_DIR/commands" ]; then
        local command_file
        for command_file in "$SOURCE_DIR"/commands/*.md; do
            [ -e "$command_file" ] || continue
            install_file "$command_file" "$TARGET_DIR/commands/$(basename "$command_file")" "~/.claude/commands/$(basename "$command_file")" || return 1
        done
    fi
    
    record_agent_install "claude-code" || return 1
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
    
    # Install .cursorrules (global rules)
    if [ -f "$SOURCE_DIR/.cursorrules" ]; then
        install_file "$SOURCE_DIR/.cursorrules" "$TARGET_DIR/.cursorrules" "~/.cursor/.cursorrules (global rules)" || return 1
    fi
    
    # Install SKILL.md (skill version)
    if [ -f "$SOURCE_DIR/SKILL.md" ]; then
        install_file "$SOURCE_DIR/SKILL.md" "$TARGET_DIR/skills/llmveritas/SKILL.md" "~/.cursor/skills/llmveritas/SKILL.md" || return 1
    fi
    
    record_agent_install "cursor" || return 1
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
    
    mkdir -p "$TARGET_DIR" || return 1
    
    # Install AGENTS.md (global instructions)
    if [ -f "$SOURCE_DIR/AGENTS.md" ]; then
        install_file "$SOURCE_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md" "~/.codex/AGENTS.md (global instructions)" || return 1
    fi
    
    # Install SKILL.md (skill version)
    if [ -f "$SOURCE_DIR/SKILL.md" ]; then
        install_file "$SOURCE_DIR/SKILL.md" "$TARGET_DIR/skills/llmveritas/SKILL.md" "~/.codex/skills/llmveritas/SKILL.md" || return 1
    fi
    
    record_agent_install "codex" || return 1
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
    if [ -f "$SOURCE_DIR/AGENTS.md" ]; then
        install_file "$SOURCE_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md" "~/.config/opencode/AGENTS.md (global instructions)" || return 1
    fi
    
    # Install SKILL.md (skill version)
    if [ -f "$SOURCE_DIR/SKILL.md" ]; then
        install_file "$SOURCE_DIR/SKILL.md" "$TARGET_DIR/skills/llmveritas.md" "~/.config/opencode/skills/llmveritas.md" || return 1
    fi
    
    record_agent_install "opencode" || return 1
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
    if [ -f "$SOURCE_DIR/SOUL.md" ]; then
        install_file "$SOURCE_DIR/SOUL.md" "$TARGET_DIR/SOUL.md" "~/.hermes/SOUL.md (primary identity)" || return 1
    fi
    
    # Install SKILL.md (skill version)
    if [ -f "$SOURCE_DIR/SKILL.md" ]; then
        install_file "$SOURCE_DIR/SKILL.md" "$TARGET_DIR/skills/llmveritas/SKILL.md" "~/.hermes/skills/llmveritas/SKILL.md" || return 1
    fi
    
    record_agent_install "hermes" || return 1
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
        install_file "$SOURCE_DIR/GEMINI.md" "$TARGET_DIR/GEMINI.md" "~/GEMINI.md (global context)" || return 1
    fi
    
    # Install SKILL.md to .gemini/skills/
    if [ -f "$SOURCE_DIR/SKILL.md" ]; then
        install_file "$SOURCE_DIR/SKILL.md" "$TARGET_DIR/.gemini/skills/llmveritas/SKILL.md" "~/.gemini/skills/llmveritas/SKILL.md" || return 1
    fi
    
    # Also install to .agents/skills/ (alternative)
    if [ -f "$SOURCE_DIR/SKILL.md" ]; then
        install_file "$SOURCE_DIR/SKILL.md" "$TARGET_DIR/.agents/skills/llmveritas/SKILL.md" "~/.agents/skills/llmveritas/SKILL.md" || return 1
    fi
    
    record_agent_install "gemini-cli" || return 1
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
    if [ -f "$SOURCE_DIR/SKILL.md" ]; then
        install_file "$SOURCE_DIR/SKILL.md" "$TARGET_DIR/llmveritas/SKILL.md" "~/.pi/agent/skills/llmveritas/SKILL.md" || return 1
    fi
    
    # Also install to .agents/skills/ alternative location
    if [ -f "$SOURCE_DIR/SKILL.md" ]; then
        install_file "$SOURCE_DIR/SKILL.md" "$HOME/.agents/skills/llmveritas/SKILL.md" "~/.agents/skills/llmveritas/SKILL.md" || return 1
    fi
    
    record_agent_install "pi" || return 1
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

ensure_state_helper

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
