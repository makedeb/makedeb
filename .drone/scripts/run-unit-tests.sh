#!/usr/bin/env bash
set -e

# Make sure Git is installed.
source "$HOME/.cargo/env"

set -x
cd test/
bats prepare/
bats "tests/${TESTS:-./}"

# vim: set syntax=bash ts=4 sw=4 expandtab:
