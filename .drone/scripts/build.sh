#!/usr/bin/env bash
set -e
sudo chown 'makedeb:makedeb' ./ -R

# Build makedeb.
export TARGET=local
export RELEASE="${release_type}"

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

export PKGVER PKGREL

cd PKGBUILD/
./pkgbuild.sh > PKGBUILD

makedeb -s --no-confirm
