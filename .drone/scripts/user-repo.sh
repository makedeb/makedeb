#!/usr/bin/env bash
set -e
sudo chown 'makedeb:makedeb' ./ -R

# Set up SSH.
rm -rf "/${HOME}/.ssh"
mkdir -p "/${HOME}/.ssh"

# Get current SSH fingerprint.
mpr_fingerprint='SHA256:7Wki/ZTENAVOYmAtH4+vhqZB8vHkLURS+eK1SQy0jTs'
aur_fingerprint='SHA256:RFzBCUItH9LZS0cKB5UE6ceAYhBD5C8GeOBip8Z11+4'
current_fingerprint="${target_repo}_fingerprint"
current_fingerprint="${!current_fingerprint}"

# Set up SSH.
echo "${ssh_key}" | tee "/${HOME}/.ssh/ssh_key"

SSH_HOST="${target_repo}_url"
SSH_HOST="${!SSH_HOST}" \
SSH_EXPECTED_FINGERPRINT="${current_fingerprint}" \
SET_PERMS="true" \
get-ssh-key

if [[ "${target_repo}" == "mpr" ]]; then
	echo "Host ${mpr_url}" | tee "/${HOME}/.ssh/config"
	echo "  Hostname ${mpr_url}" | tee -a "/${HOME}/.ssh/config"
	echo "  IdentityFile /${HOME}/.ssh/ssh_key" | tee -a "/${HOME}/.ssh/config"

else
	echo "Host ${aur_url}" | tee "/${HOME}/.ssh/config"
	echo "  Hostname ${aur_url}" | tee -a "/${HOME}/.ssh/config"
	echo "  IdentityFile /${HOME}/.ssh/ssh_key" | tee -a "/${HOME}/.ssh/config"

fi

chmod 500 "/${HOME}/.ssh/"* -R

# Clone AUR/MPR Package.
if [[ "${target_repo}" == "mpr" ]]; then
	git clone "ssh://mpr@${mpr_url}/${package_name}.git" "${package_name}_${target_repo}"
else
	git clone "ssh://aur@${aur_url}/${package_name}.git" "${package_name}_${target_repo}"
fi

# Copy PKGBUILD to user repo.
export TARGET="${target_repo}"
export RELEASE="${release_type}"

rm "${package_name}_${target_repo}/PKGBUILD"
cd PKGBUILD/
./pkgbuild.sh > "../${package_name}_${target_repo}/PKGBUILD"

# Create .SRCINFO file
cd "../${package_name}_${target_repo}"

PACMAN='/usr/bin/true' makedeb --printsrcinfo | tee .SRCINFO

# Remove 'generated-by' line when using AUR deployments.
if [[ "${target_repo}" == "aur" ]]; then
	sed -i '1,2d' .SRCINFO
	cat .SRCINFO
fi

# Check if changes have been made
if [[ "$(git diff)" == "" ]]; then
  exit 0
fi


# Set up Git identity information
git config user.name "Kavplex Bot"
git config user.email "kavplex@hunterwittenborn.com"

# Get current version info.
config="$(cat ../.data.json)"
pkgver="$(echo "${config}" | jq -r '.current_pkgver')"
pkgrel="$(echo "${config}" | jq -r '.current_pkgrel')"

# Commit changes and push
git add PKGBUILD .SRCINFO
git commit -m "Updated version to ${pkgver}-${pkgrel}"

git push
