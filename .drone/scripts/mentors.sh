#!/usr/bin/env bash
set -e

cp files/dput.cf $HOME/.dput.cf

export NEEDED_VERSION="$(cat .data.json | jq -r '.current_pkgver')"
dput mentors "../${pkgname}_${NEEDED_VERSION}-1_source.changes"
