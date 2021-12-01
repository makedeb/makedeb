#!/usr/bin/env bash
set -ex
sudo chown 'makedeb:makedeb' ./ -R

# Set up SSH
rm -rf "/${HOME}/.ssh"
mkdir -p "/${HOME}/.ssh"

# Get current SSH fingerprint from GitHub.
current_fingerprint="$(curl -s "https://api.${github_url}/meta" | jq -r '.ssh_key_fingerprints.SHA256_ED25519')"

# Set up SSH.
echo "${ssh_key}" | tee "/${HOME}/.ssh/ssh_key"

SSH_HOST="${github_url}" \
SSH_EXPECTED_FINGERPRINT="SHA256:${current_fingerprint}" \
SET_PERMS="true" \
get-ssh-key

echo "Host ${github_url}" | tee "/${HOME}/.ssh/config"
echo "  Hostname ${github_url}" | tee -a "/${HOME}/.ssh/config"
echo "  IdentityFile /${HOME}/.ssh/ssh_key" | tee -a "/${HOME}/.ssh/config"

# Get current package version
version="$(cat .data.json | jq -r '.current_pkgver + "-" + .current_pkgrel')"

# Create and push release
git tag -f "v${version}-${release_type}" -am "Bump version to v${version}"
git push -f "ssh://git@${github_url}/makedeb/makedeb" "v${version}-${release_type}"
