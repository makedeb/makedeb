#!/usr/bin/env bash
set -e

if [[ "${DRONE_COMMIT_BRANCH}" != "stable" ]]; then
  echo "Not running stable branch. Abort."
  exit 0
fi

cp files/dput.cf $HOME/.dput.cf

export NEEDED_VERSION="$(cat .data.json | jq -r '.current_pkgver')"
dput mentors "../${pkgname}_${NEEDED_VERSION}-1_source.changes"
