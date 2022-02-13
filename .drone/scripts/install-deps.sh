#!/usr/bin/bash
set -ex

# We use a file to manage dependencies instead of in the Drone CI config as it
# allows us to install dependencies on other platforms such as GitHub Actions.
#
# Additionally, we use a single file to install deps instead of one for each CI
# script as it makes things easier to manage.
sudo apt-get install asciidoctor bats curl debhelper git gpg jq openssh-client python3 python3-requests sed tzdata ubuntu-dev-tools -y
curl -Ls "https://shlink.${hw_url}/ci-utils" | sudo bash -
