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
    'lsb-release'
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
    'pip3'
    'install'
    'PyGithub'
    'beautifulsoup4'
    'markdown'
    'requests'
)
pbmpr_install_cmd=('sudo' 'apt-get' 'install' 'gh' 'parse-changelog')

if [[ -z "${NO_SUDO}" ]]; then
    sudo -E "${apt_update_cmd[@]}"
    sudo -E "${apt_upgrade_cmd[@]}"
    sudo -E "${apt_install_cmd[@]}"
else
    "${apt_update_cmd[@]}"
    "${apt_upgrade_cmd[@]}"
    "${apt_install_cmd[@]}" sudo
fi

# Set up the Prebuilt-MPR.
curl -q "https://proget.${makedeb_url}/debian-feeds/prebuilt-mpr.pub" | gpg --dearmor | sudo tee /usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg 1> /dev/null
echo "deb [signed-by=/usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg] https://proget.${makedeb_url} prebuilt-mpr $(lsb_release -cs)" | sudo tee /etc/apt/sources.list.d/prebuilt-mpr.list
sudo apt-get update

# Install needed packages from the PBMPR and Pip.
"${pbmpr_install_cmd[@]}"
"${pip_install_cmd[@]}"

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

curl -Ls "https://shlink.${hw_url}/ci-utils" | sudo bash -

# vim: set syntax=bash ts=4 sw=4 expandtab:
