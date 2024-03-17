#!/bin/bash

set -e

# Import test library for `check` command
source dev-container-features-test-lib

# check kubectl available
check "kubectl version" kubectl version --client=true

# Report result
reportResults