#!/usr/bin/env bash
set -e

if git log -1 --pretty='%s' | grep '\[TEST SKIP\]$'; then
    echo "Skipping unit tests..."
    exit 0
fi

set -x
cd test/
bats prepare/
bats tests/

# vim: set syntax=bash ts=4 sw=4 expandtab:
