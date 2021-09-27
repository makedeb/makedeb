#!/usr/bin/env bash
set -exuo pipefail

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
package_version="$(cat "src/PKGBUILD" | grep '^pkgver=' | awk -F '=' '{print $2}')"

# Create and push release
git tag "v${package_version}-${release_type}" -am ""
git push "ssh://git@${github_url}/makedeb/makedeb" "v${package_version}-${release_type}"
