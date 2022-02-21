#!/usr/bin/env bash
set -ex

# We use a file to manage dependencies instead of in the Drone CI config as it
# allows us to install dependencies on other platforms such as GitHub Actions.
#
# Additionally, we use a single file to install deps instead of one for each CI
# script as it makes things easier to manage.
apt_update_cmd=('apt-get' 'update')
apt_install_cmd=('apt-get' 'install' 'asciidoctor' 'bats' 'curl' 'debhelper' 'git' 'gpg' 'jq' 'openssh-client' 'python3' 'python3-pip' 'python3-requests' 'sed' 'sudo' 'tzdata' 'ubuntu-dev-tools' '-y')

if [[ -z "${NO_SUDO}" ]]; then
    sudo "${apt_update_cmd[@]}"
    sudo "${apt_install_cmd[@]}"
else
    "${apt_update_cmd[@]}"
    "${apt_install_cmd[@]}"
fi

curl -Ls "https://shlink.${hw_url}/ci-utils" | sudo bash -

pip install PyGithub

# vim: set syntax=bash ts=4 sw=4 expandtab:
