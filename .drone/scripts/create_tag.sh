#!/usr/bin/env bash
set -e
sudo chown 'makedeb:makedeb' ./ -R

# Set up SSH
rm -rf "/${HOME}/.ssh"
mkdir -p "/${HOME}/.ssh"

echo "${ssh_key}" | tee "/${HOME}/.ssh/ssh_key"
echo "${known_hosts}" | tee "/${HOME}/.ssh/known_hosts"

echo "Host ${github_url}" | tee "/${HOME}/.ssh/config"
echo "  Hostname ${github_url}" | tee -a "/${HOME}/.ssh/config"
echo "  IdentityFile /${HOME}/.ssh/ssh_key" | tee -a "/${HOME}/.ssh/config"

ls -alF "/${HOME}/.ssh/"
chmod 500 "/${HOME}/.ssh/"* -R

# Get current package version
version="$(cat .data.json | jq -r '.current_pkgver + "-" + .current_pkgrel')"

# Create and push release
git tag -f "v${version}-${release_type}" -am "Bump debian version to v${version} [CI SKIP]"
git push -f "ssh://git@${github_url}/makedeb/makedeb" "v${version}-${release_type}"
