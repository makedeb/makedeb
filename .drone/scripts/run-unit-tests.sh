#!/usr/bin/bash
set -ex

cd test/

bats prepare/

# Arguments may be passed to be this script to selectively run certain tests, such as when running from the local Docker Compose setup.
if [[ -z "${@}" ]]; then
    bats tests/
else
    bats "${@}"
fi

# vim: set syntax=bash ts=4 sw=4 expandtab:
