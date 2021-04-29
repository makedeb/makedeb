set -x
# INSTALL CURL
export DEBIAN_FRONTEND=noninteractive
apt update
apt dist-upgrade -y
apt install curl -y
# PUBLISH PACKAGE TO REPOSITORY
package="$(ls *.deb)"
## EXIT WITH CODE 1 IF MULTIPLE PACKAGES WERE LISTED IN PACKAGE DIRECTORY
if [ "$(echo ${package[@]} | awk -F ' ' '{print $2}')" != "" ]; then exit 1; fi

curl -u "system:${nexus_pass}" \
     -H "Content-Type: multipart/form-data" \
     --data-binary "@${package}" \
     "https://nexus.hunterwittenborn.com/repository/makedeb/"
