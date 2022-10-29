#!/usr/bin/env bash
sudo apt-get update
sudo apt-get install git -y

if (git log -1 --pretty='%s' | grep '\[TEST SKIP\]$') || ([[ "${TEST_SKIP:+x}" == 'x' ]]); then
    echo "Skipping unit tests..."
    exit 0
fi

.drone/scripts/install-deps.sh
source "${HOME}/.cargo/env"
.drone/scripts/run-unit-tests.sh