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

# Create and push release
git tag "v${PKGVER}-${release_type}" -am ""
git push "ssh://git@${github_url}/makedeb/makedeb" "v${PKGVER}-${release_type}"
