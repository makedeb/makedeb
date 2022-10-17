#!/usr/bin/bash
set -e

# REMOVE BEFORE MERGING!!!
echo "${PATH}" &> /dev/stderr

if (git log -1 --pretty='%s' | grep '\[TEST SKIP\]$') || ([[ "${TEST_SKIP:+x}" == 'x' ]]); then
    echo "Skipping unit tests..."
    exit 0
fi

set -x
cd test/
bats prepare/
bats "tests/${TESTS:-./}"

# vim: set syntax=bash ts=4 sw=4 expandtab:
