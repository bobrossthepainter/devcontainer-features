#!/usr/bin/env bash

set -e

export DEBIAN_FRONTEND=noninteractive

curl -fsSL https://claude.ai/install.sh | bash

echo "Done!"
