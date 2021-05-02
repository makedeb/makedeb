#!/usr/bin/env bash
set -e

# Install curl
echo "+ Install curl"
apt update
apt install curl -y

# Make sure only a single package is present
echo "+ Checking number of packages present"
cd src
package="$(find *.deb)"
if [[ "$(echo ${package[@]} | wc -w)" != "1" ]]; then
  echo "More than one package was present"
  exit 1
fi

# Push package to repository
echo "+ Pushing package to repository"
curl_output=$(curl -s \
                   -u "system:${nexus_repository_password}" \
                   -H "Content-Type: multipart/form-data" \
                   --data-binary "@./${package}" \
                   "https://nexus.hunterwittenborn.com/repository/makedeb/")

if [[ "${curl_output}" != "" ]]; then
  echo "${curl_output}"
  echo "An error occured when uploading the package"
  exit 1
fi
