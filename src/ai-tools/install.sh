#!/usr/bin/env bash

set -e

export DEBIAN_FRONTEND=noninteractive

CLAUDE="${CLAUDE:-false}"
CODEX="${CODEX:-false}"

if [ "$CLAUDE" = "true" ]; then
    echo "Installing Claude Code CLI..."
    curl -fsSL https://claude.ai/install.sh | bash
fi

if [ "$CODEX" = "true" ]; then
    echo "Installing OpenAI Codex CLI..."
    npm install -g @openai/codex
fi

echo "Done!"
