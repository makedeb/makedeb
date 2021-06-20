#!/usr/bin/env bash

cd src
component_name="$(cat PKGBUILD | grep 'pkgname=' | sed 's|pkgname=||')"

# Check for build debs
deb_packages=$(find *.deb 2> /dev/null)
deb_packages_count=$(echo "${deb_packages}" | wc -w)

if [[ "${deb_packages_count}" == "0" ]]; then
    echo "ERROR: There doesn't appear to be any packages present."
    exit 1

elif [[ "${deb_packages_count}" -gt "1" ]]; then
    echo "ERROR: More than one package is present."
    exit 1
fi

echo "Uploading ${deb_packages} to ${proget_server}..."

set -x
curl_output=$(curl "https://${proget_server}/debian-packages/upload/makedeb/main/${deb_packages}" \
            --user "api:${proget_api_key}" \
            --upload-file "${deb_packages}")
