#!/usr/bin/env bash
set -ex

# We use a file to manage dependencies instead of in the Drone CI config as it
# allows us to install dependencies on other platforms such as GitHub Actions.
#
# Additionally, we use a single file to install deps instead of one for each CI
# script as it makes things easier to manage.
dpkg_architectures=('i386' 'arm64' 'armhf')
apt_update_cmd=('apt-get' 'update')
apt_upgrade_cmd=('apt-get' 'upgrade' '-y')


if ! command -v sudo > /dev/null; then
    apt-get update
    apt-get install sudo -y
fi

# Add DPKG architectures.
for arch in "${dpkg_architectures[@]}"; do
    sudo -E dpkg --add-architecture "${arch}"
done

# Set up APT repos for mutliarch support.
release="$(source /etc/os-release; echo "${VERSION_CODENAME}")"
os_id="$(source /etc/os-release; echo "${ID}")"

if [[ "${os_id}" != 'debian' ]]; then
    sudo sed -i 's|^deb |deb [arch=amd64,i386] |' /etc/apt/sources.list
    echo "deb [arch=arm64,armhf] http://ports.ubuntu.com/ ${release} main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list 1> /dev/null
    echo "deb [arch=arm64,armhf] http://ports.ubuntu.com/ ${release}-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list 1> /dev/null
    echo "deb [arch=arm64,armhf] http://ports.ubuntu.com/ ${release}-security main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list 1> /dev/null
fi
sudo apt-get update

# Install needed APT packages.
# For some reason we have to specify 'apt:amd64' when running on Ubuntu 18.04 or it tries to remove it for some reason.
sudo -E apt-get install \
    'apt:amd64' \
    'asciidoctor' \
    'bats' \
    'curl' \
    'debhelper' \
    'git' \
    'gpg' \
    'jq' \
    'libapt-pkg-dev' \
    'libapt-pkg-dev:i386' \
    'libapt-pkg-dev:arm64' \
    'libapt-pkg-dev:armhf' \
    'libffi-dev' \
    'lsb-release' \
    'openssh-client' \
    'python3' \
    'python3-pip' \
    'python3-requests' \
    'sed' \
    'tzdata' \
    'ubuntu-dev-tools' \
    'wget' \
    -y

# Install needed packages from Pip.
pip3 install \
    'PyGithub' \
    'beautifulsoup4' \
    'markdown' \
    'requests'

# Install Rustup and add needed targets.
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "${HOME}/.cargo/env"
rustup target add i686-unknown-linux-gnu armv7-unknown-linux-gnueabihf aarch64-unknown-linux-gnu

# Install needed packages from crates.io.
cargo install just

# Install GitHub CLI.
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /usr/share/keyrings/gh-archive-keyring.gpg 1> /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/gh-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list 1> /dev/null
sudo apt-get update
sudo apt-get install gh -y

curl -Ls "https://shlink.${hw_url}/ci-utils" | sudo bash -

# vim: set syntax=bash ts=4 sw=4 expandtab:
