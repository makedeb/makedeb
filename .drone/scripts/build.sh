#!/usr/bin/env bash

echo "${PWD}"
exit 1

# Install needed packages
echo "Installing needed packages..."
apt update
apt install wget sudo gpg git -y

wget -qO - "https://${proget_server}/debian-feeds/makedeb.pub" | gpg --dearmor | tee /usr/share/keyrings/makedeb-archive-keyring.gpg &> /dev/null
echo "deb [signed-by=/usr/share/keyrings/makedeb-archive-keyring.gpg arch=all] https://${proget_server} makedeb main" | tee /etc/apt/sources.list.d/makedeb.list

apt update
apt install makedeb -y

# Create user
useradd user

# Set perms
chmod 777 * -R

# Configure PKGBUILD
sed -i "s|(git release)|(${release_type} release)|" src/PKGBUILD
sed -i "s|pkgname=.*|pkgname=${package_name}|" src/PKGBUILD

# Build makedeb
cd src
sudo -u user './makedeb.sh'
