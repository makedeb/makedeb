#!/usr/bin/bash
set -e

# Make sure Git is installed.
sudo apt-get update
sudo apt-get install git -y

if (git log -1 --pretty='%s' | grep '\[TEST SKIP\]$') || ([[ "${TEST_SKIP:+x}" == 'x' ]]); then
    echo "Skipping unit tests..."
    exit 0
fi

.drone/scripts/install-deps.sh
source "$HOME/.cargo/env"

set -x
cd test/
bats prepare/
bats "tests/${TESTS:-./}"

# vim: set syntax=bash ts=4 sw=4 expandtab:
