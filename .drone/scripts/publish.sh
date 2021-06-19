#!/usr/bin/env bash

exit 0
# Set up makedeb repo
echo "Installing needed packages..."
apt update
apt install wget curl gpg -y

wget -qO - "https://${proget_server}/debian-feeds/makedeb.pub" | gpg --dearmor | tee /usr/share/keyrings/makedeb-archive-keyring.gpg &> /dev/null
echo "deb [signed-by=/usr/share/keyrings/makedeb-archive-keyring.gpg arch=all] https://${proget_server} makedeb main" | tee /etc/apt/sources.list.d/makedeb.list

apt update
apt install makedeb-alpha -y

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
