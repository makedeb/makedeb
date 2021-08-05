#!/usr/bin/env bash
set -exuo pipefail

# Set up SSH
rm -rf /root/.ssh
mkdir -p /root/.ssh

echo "${ssh_key}" | tee /root/.ssh/ssh_key
echo "${known_hosts}" | tee /root/.ssh/known_hosts

if [[ "${target_repo}" == "mpr" ]]; then
	echo "Host ${mpr_url}" | tee /root/.ssh/config
	echo "  Hostname ${mpr_url}" | tee -a /root/.ssh/config
	echo "  IdentityFile /root/.ssh/ssh_key" | tee -a /root/.ssh/config

else
	echo "Host ${aur_url}" | tee /root/.ssh/config
	echo "  Hostname ${aur_url}" | tee -a /root/.ssh/config
	echo "  IdentityFile /root/.ssh/ssh_key" | tee -a /root/.ssh/config

fi

chmod 400 /root/.ssh/ -R

# Clone AUR/MPR Package
if [[ "${target_repo}" == "mpr" ]]; then
	git clone "ssh://mpr@${mpr_url}/${package_name}.git" "${package_name}_${target_repo}"

else
	git clone "ssh://aur@${aur_url}/${package_name}.git" "${package_name}_${target_repo}"

fi

# Copy PKGBUILD to user repo
rm "${package_name}_${target_repo}/PKGBUILD"
cp "PKGBUILDs/${target_repo^^}/${release_type^^}.PKGBUILD" "${package_name}_${target_repo}/PKGBUILD"

# Get current pkgver and pkgrel
pkgver="$(cat src/PKGBUILD | grep '^pkgver=' |awk -F'=' '{print $2}')"
pkgrel="$(cat src/PKGBUILD | grep '^pkgrel=' |awk -F'=' '{print $2}')"

# Set package version in PKGBUILD
sed -i "s|^pkgver={pkgver}|pkgver=${pkgver}|" "${package_name}_${target_repo}/PKGBUILD"

# Create build user for creating .SRCINFO file
useradd user

# Create .SRCINFO file
chown "user:user" "${package_name}_${target_repo}" -R
cd "${package_name}_${target_repo}"

sudo -u user -- makepkg --printsrcinfo | tee .SRCINFO

# Set up Git identity information
git config user.name "Kavplex Bot"
git config user.email "kavplex@hunterwittenborn.com"

# Commit changes and push
git add PKGBUILD .SRCINFO
git commit -m "Updated version to ${pkgver}-${pkgrel}"

git push
