#!/usr/bin/env bash
set -exuo pipefail

# Set up SSH
rm -rf /root/.ssh
mkdir -p /root/.ssh

echo "${ssh_key}" | tee /root/.ssh/ssh_key
echo "${known_hosts}" | tee /root/.ssh/known_hosts

echo "Host ${github_url}" | tee /root/.ssh/config
echo "  Hostname ${github_url}" | tee -a /root/.ssh/config
echo "  IdentityFile /root/.ssh/ssh_key" | tee -a /root/.ssh/config

chmod 400 /root/.ssh/ -R

# Get current package version
package_version="$(cat "src/PKGBUILD" | grep '^pkgver=' | awk -F '=' '{print $2}')"

# Create and push release
git tag "v${package_version}-${release_type}"
git push "ssh://git@${github_url}/makedeb/makedeb" "v${package_Version}-${release_type}"
