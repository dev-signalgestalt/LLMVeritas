#!/bin/bash
# LLMVeritas One-Command Setup
# Usage: ./setup.sh <agent>
# Agents: claude-code, cursor, codex, opencode, hermes, gemini-cli, pi, all

set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SCRIPT_DIR/.venv"

AGENT="${1:-}"

if [ -z "$AGENT" ]; then
    echo "Usage: ./setup.sh <agent>"
    echo
    echo "Agents:"
    echo "  claude-code    Claude Code"
    echo "  cursor         Cursor"
    echo "  codex          Codex CLI"
    echo "  opencode       OpenCode"
    echo "  hermes         Hermes Agent"
    echo "  gemini-cli     Gemini CLI"
    echo "  pi             Pi Coding Agent"
    echo "  all            Install for all 7 agents"
    echo
    echo "Example:"
    echo "  ./setup.sh claude-code"
    exit 1
fi

echo "🔧 LLMVeritas Setup"
echo "===================="
echo

# Step 1: Create virtual environment
if [ ! -d "$VENV_DIR" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv "$VENV_DIR" || { echo "❌ Failed to create venv. Install python3-venv first."; exit 1; }
    echo "   ✅ Created .venv/"
else
    echo "📦 Virtual environment already exists, reusing."
fi

# Step 2: Install dependencies
echo "📥 Installing build dependencies..."
if "$VENV_DIR/bin/pip" install -r "$SCRIPT_DIR/requirements.txt" -q 2>&1 | tail -1; then
    echo "   ✅ Dependencies installed"
else
    echo "❌ Failed to install build dependencies."
    exit 1
fi

# Step 3: Build adapter files
echo "🏗️  Building adapter files..."
"$VENV_DIR/bin/python3" "$SCRIPT_DIR/scripts/build.py"
echo "   ✅ Build complete"

# Step 4: Install for target agent
echo "📦 Installing for: $AGENT"
"$SCRIPT_DIR/scripts/install.sh" "$AGENT"

echo
echo "======================"
echo "✅ LLMVeritas setup complete!"
echo
echo "What was installed:"
echo "  - Build dependencies in .venv/"
echo "  - Generated adapter files in generated/"
echo "  - Agent config files in your home directory"
echo
echo "To rebuild after editing core/ or templates/:"
echo "  .venv/bin/python3 scripts/build.py"
echo "  ./scripts/install.sh $AGENT"
echo
echo "To pull future changes and reinstall:"
echo "  ./update.sh $AGENT"
