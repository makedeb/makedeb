#!/usr/bin/bash
set -ex

cd test/
bats prepare/
bats tests/pkgmaint-scripts.bats
