#!/usr/bin/env bash
set -e

# Set up a temporary directory that only exists inside the container. We'll use this so we avoid any mucking around with the user's own copy of the Git repository.
rm -rf /tmp/makedeb-tmp/
cp /tmp/makedeb/ /tmp/makedeb-tmp/ -r
cd /tmp/makedeb-tmp/

# Make sure the temp directory is writable by the 'makedeb' user.
chown makedeb:makedeb ../ -R

# We use Git to fetch a few things before unit tests run, so we need to make sure we can properly clone the makedeb Git repository by setting it to the public-facing Git URL.
git remote set-url origin 'https://github.com/makedeb/makedeb'

# Actually run the unit tests.
sudo -u makedeb .drone/scripts/run-unit-tests.sh "${@}"
