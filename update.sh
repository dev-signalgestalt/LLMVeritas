#!/bin/bash
# LLMVeritas Update Command
# Usage: ./update.sh [agent|all]

set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SCRIPT_DIR/.venv"
STATE_HELPER="$SCRIPT_DIR/scripts/install_state.py"
PYTHON_BIN="$VENV_DIR/bin/python3"
PIP_BIN="$VENV_DIR/bin/pip"
AGENT="${1:-}"

if [ ! -x "$PYTHON_BIN" ]; then
    PYTHON_BIN="${PYTHON:-python3}"
fi

if [ ! -x "$PIP_BIN" ]; then
    PIP_BIN="$VENV_DIR/bin/pip"
fi

echo "🔄 LLMVeritas Update"
echo "===================="
echo

if [ $# -gt 1 ]; then
    echo "Usage: ./update.sh [agent|all]"
    exit 1
fi

if [ ! -f "$STATE_HELPER" ]; then
    echo "❌ Missing install-state helper: $STATE_HELPER"
    exit 1
fi

if ! git -C "$SCRIPT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "❌ update.sh must be run inside the LLMVeritas git checkout."
    exit 1
fi

RECORDED_REPO="$("$PYTHON_BIN" "$STATE_HELPER" repo-path 2>/dev/null || true)"
CURRENT_REPO="$(cd "$SCRIPT_DIR" && pwd)"

if [ -n "$RECORDED_REPO" ] && [ "$RECORDED_REPO" != "$CURRENT_REPO" ]; then
    echo "⚠️  Install state points to a different repo path:"
    echo "   recorded: $RECORDED_REPO"
    echo "   current:  $CURRENT_REPO"
    echo "   Continuing with the current checkout."
    echo
fi

if [ "${LLMVERITAS_SKIP_GIT_PULL:-0}" = "1" ]; then
    echo "📡 Skipping git pull (LLMVERITAS_SKIP_GIT_PULL=1)"
else
    echo "📡 Pulling latest repo changes..."
    git -C "$SCRIPT_DIR" pull --ff-only
fi

echo

if [ ! -d "$VENV_DIR" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv "$VENV_DIR" || { echo "❌ Failed to create venv. Install python3-venv first."; exit 1; }
    echo "   ✅ Created .venv/"
else
    echo "📦 Reusing virtual environment..."
fi

echo "📥 Installing build dependencies..."
if "$PIP_BIN" install -r "$SCRIPT_DIR/requirements.txt" -q 2>&1 | tail -1; then
    echo "   ✅ Dependencies installed"
else
    echo "❌ Failed to install build dependencies."
    exit 1
fi

echo "🏗️  Building adapter files..."
"$VENV_DIR/bin/python3" "$SCRIPT_DIR/scripts/build.py"
echo "   ✅ Build complete"
echo

TARGETS=()
if [ -n "$AGENT" ]; then
    if [ "$AGENT" = "all" ]; then
        TARGETS=("all")
    else
        TARGETS=("$AGENT")
    fi
else
    mapfile -t TARGETS < <("$VENV_DIR/bin/python3" "$STATE_HELPER" list-installed 2>/dev/null || true)
    if [ ${#TARGETS[@]} -eq 0 ]; then
        echo "❌ No installed agents found in ~/.llmveritas/install-state.json"
        echo "   Run ./setup.sh <agent> first, or specify an agent explicitly."
        exit 1
    fi
fi

export LLMVERITAS_BACKUP_SESSION_DIR="$("$VENV_DIR/bin/python3" "$STATE_HELPER" create-backup-session)"

UPDATED_AGENTS=()

if [ "${TARGETS[0]}" = "all" ]; then
    echo "📦 Updating all supported agents..."
    "$SCRIPT_DIR/scripts/install.sh" all
    UPDATED_AGENTS=("claude-code" "cursor" "codex" "opencode" "hermes" "gemini-cli" "pi")
else
    echo "📦 Updating installed targets: ${TARGETS[*]}"
    echo
    for target in "${TARGETS[@]}"; do
        "$SCRIPT_DIR/scripts/install.sh" "$target"
        UPDATED_AGENTS+=("$target")
        echo
    done
fi

echo "===================="
echo "✅ LLMVeritas update complete!"
echo "Updated agents: ${UPDATED_AGENTS[*]}"
echo "Backup session: $LLMVERITAS_BACKUP_SESSION_DIR"
