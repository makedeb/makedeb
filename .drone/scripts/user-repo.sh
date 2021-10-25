#!/usr/bin/env bash
set -e
sudo chown 'makedeb:makedeb' ./ -R

# Get package version.
read PKGVER PKGREL < <(echo "${DRONE_COMMIT_MESSAGE}" | grep '^Package Version:' | awk -F ': ' '{print $2}' | sed 's|-| |g')

for i in PKGVER PKGREL; do
	if [[ "${!i}" == "" ]]; then
		echo "ERROR: ${i} isn't set."
		echo "Please make sure your commit message contained a 'Package Version' line."
		bad_commit_message="x"
	fi
done

if [[ "${bad_commit_meesage:+x}" == "x" ]]; then
	echo "COMMIT MESSAGE:"
	echo "==============="
	echo "${DRONE_COMMIT_MESSAGE}"
	exit 1
fi

# Set up SSH.
rm -rf "/${HOME}/.ssh"
mkdir -p "/${HOME}/.ssh"

echo "${ssh_key}" | tee "/${HOME}/.ssh/ssh_key"
echo "${known_hosts}" | tee "/${HOME}/.ssh/known_hosts"

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
export PKGVER
export PKGREL

rm "${package_name}_${target_repo}/PKGBUILD"
cd PKGBUILD/
./pkgbuild.sh > "../${package_name}_${target_repo}/PKGBUILD"

# Create .SRCINFO file
cd "../${package_name}_${target_repo}"

makedeb --printsrcinfo | tee .SRCINFO

# Remove 'generated-by' line when using AUR deployments.
if [[ "${target_repo}" == "aur" ]]; then
	sed -i '1,2d' .SRCINFO
	cat .SRCINFO
fi

# Set up Git identity information
git config user.name "Kavplex Bot"
git config user.email "kavplex@hunterwittenborn.com"

# Commit changes and push
git add PKGBUILD .SRCINFO
git commit -m "Updated version to ${PKGVER}-${PKGREL}"

git push
