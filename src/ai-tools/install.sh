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
    echo "Installing bubblewrap sandbox..."
    apt-get update -y
    apt-get install -y bubblewrap
    rm -rf /var/lib/apt/lists/*
    echo "Installing OpenAI Codex CLI..."
    npm install -g @openai/codex
fi

// pi
if [ "$PI" = "true" ]; then
    echo "Installing git-delta and glow for Pi..."
    apt-get update -y
    apt-get install -y bat git-delta glow
    rm -rf /var/lib/apt/lists/*
    curl -fsSL https://pi.dev/install.sh | bash
fi

echo "Done!"
