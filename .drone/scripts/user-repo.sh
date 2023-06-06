#!/usr/bin/env bash
set -e
sudo chown 'makedeb:makedeb' ./ -R

# Set up SSH.
rm -rf "/${HOME}/.ssh"
mkdir -p "/${HOME}/.ssh"

# Get current SSH fingerprint.
mpr_fingerprint="$(curl "https://${mpr_url}/api/meta" | jq -r '.ssh_key_fingerprints.ECDSA')"

# Set up SSH.
echo "${ssh_key}" | tee "/${HOME}/.ssh/ssh_key"

SSH_HOST="${mpr_url}" \
SSH_EXPECTED_FINGERPRINT="${mpr_fingerprint}" \
SET_PERMS="true" \
get-ssh-key

echo "Host ${mpr_url}" | tee "/${HOME}/.ssh/config"
echo "  Hostname ${mpr_url}" | tee -a "/${HOME}/.ssh/config"
echo "  IdentityFile /${HOME}/.ssh/ssh_key" | tee -a "/${HOME}/.ssh/config"

chmod 500 "/${HOME}/.ssh/"* -R

# Clone MPR Package.
git clone "ssh://mpr@${mpr_url}/${package_name}.git" "${package_name}"

# Copy PKGBUILD to user repo.
export TARGET='mpr'
export RELEASE="${release_type}"

rm "${package_name}/PKGBUILD"
cd PKGBUILD/
./pkgbuild.sh > "../${package_name}/PKGBUILD"

# Create .SRCINFO file
cd "../${package_name}"

makedeb --print-srcinfo | tee .SRCINFO

# Check if changes have been made
if [[ "$(git diff)" == "" ]]; then
  exit 0
fi


# Set up Git identity information
git config user.name "Kavplex Bot"
git config user.email "kavplex@hunterwittenborn.com"

# Get current version info.
pkgver="$(source PKGBUILD; echo "${pkgver}")"
pkgrel="$(source PKGBUILD; echo "${pkgrel}")"

# Commit changes and push
git add PKGBUILD .SRCINFO
git commit -m "Updated version to ${pkgver}-${pkgrel}"

git push
