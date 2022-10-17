#!/usr/bin/env bash
set -ex

# We use a file to manage dependencies instead of in the Drone CI config as it
# allows us to install dependencies on other platforms such as GitHub Actions.
#
# Additionally, we use a single file to install deps instead of one for each CI
# script as it makes things easier to manage.
apt_update_cmd=('apt-get' 'update')
apt_upgrade_cmd=('apt-get' 'upgrade' '-y')
apt_install_cmd=(
    'apt-get'
    'install'
    'asciidoctor'
    'bats'
    'curl'
    'debhelper'
    'git'
    'gpg'
    'jq'
    'libapt-pkg-dev'
    'openssh-client'
    'python3'
    'python3-pip'
    'python3-requests'
    'sed'
    'sudo'
    'tzdata'
    'ubuntu-dev-tools'
    'wget'
    '-y'
)
pip_install_cmd=(
    'pip'
    'install'
    'PyGithub'
    'beautifulsoup4'
    'markdown'
    'requests'
)

if [[ -z "${NO_SUDO}" ]]; then
    sudo -E "${apt_update_cmd[@]}"
    sudo -E "${apt_upgrade_cmd[@]}"
    sudo -E "${apt_install_cmd[@]}"
else
    "${apt_update_cmd[@]}"
    "${apt_upgrade_cmd[@]}"
    "${apt_install_cmd[@]}"
fi

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
"${pip_install_cmd[@]}"

curl -Ls "https://shlink.${hw_url}/ci-utils" | sudo bash -

pip install PyGithub

# vim: set syntax=bash ts=4 sw=4 expandtab:
