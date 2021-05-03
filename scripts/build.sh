#!/usr/bin/env bash
set -e

# Install needed packages
echo "+ Installing needed packages"
apt update
apt install sudo wget gettext-base -y

# Set up PKGBUILD
echo "+ Setting up PKGBUILD"
if [[ "${release_type}" == "stable" ]]; then
  export pkgname="makedeb"
elif [[ "${release_type}" == "alpha" ]]; then
  export pkgname="makedeb-alpha"
  sed -i "s/conflicts=.*/conflicts=('makedeb')/" src/PKGBUILD
fi

for i in pkgname release_type; do
  variable_name="\${$i}"
  variable_product="$(eval echo \${$i})"
  sed -i "s;$variable_name;$variable_product;g" src/PKGBUILD
done

# Set up repository and install current copy of makedeb
echo "+ Setting up repository"
wget 'https://hunterwittenborn.com/keys/apt.asc' -O /etc/apt/trusted.gpg.d/hwittenborn.asc
echo 'deb [arch=all] https://repo.hunterwittenborn.com/debian/makedeb any main' | sudo tee /etc/apt/sources.list.d/makedeb.list

echo "+ Installing current copy of makedeb"
apt update
apt install makedeb -y

# Set folder perms and build makedeb
echo "+ Setting folder perms"
chmod a+rwx src -R

echo "+ Building makedeb with makedeb.sh"
cd src
sudo -u nobody ./makedeb.sh
