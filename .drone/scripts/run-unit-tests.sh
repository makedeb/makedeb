#!/usr/bin/bash
set -ex

cd test/
bats prepare/
bats tests/backup.bats

# vim: set syntax=bash ts=4 sw=4 expandtab:
