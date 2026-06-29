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

if [ "$PI" = "true" ]; then
    # DELTA_VERSION=0.19.2
    # GLOW_VERSION=2.1.2

    # echo "Installing git-delta and glow for Pi..."
    # ARCH="$(dpkg --print-architecture)" && \
    # curl -fsSL "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_${ARCH}.deb" -o /tmp/git-delta.deb && \
    # curl -fsSL "https://github.com/charmbracelet/glow/releases/download/v${GLOW_VERSION}/glow_${GLOW_VERSION}_${ARCH}.deb" -o /tmp/glow.deb && \
    # dpkg -i /tmp/git-delta.deb /tmp/glow.deb && \
    # rm -f /tmp/git-delta.deb /tmp/glow.deb

    # echo "Installing bat for Pi..."
    # apt-get update -y
    # apt-get install -y bat
    # mkdir -p root/.local/bin
    # ln -s /usr/bin/batcat /usr/local/bin/bat
    # rm -rf /var/lib/apt/lists/*

    echo "Installing Pi..."
    npm install -g --ignore-scripts @earendil-works/pi-coding-agent
    pi install git:git@github.com:bobrossthepainter/pi-diff-view
fi

echo "Done!"
