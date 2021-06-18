#!/usr/bin/env bash

# Install packages
echo "Installing needed packages..."
apt update
apt install ssh git -y

# Define functions
aur_clone() {
    cd ..
    git clone "https://${aur_url}/${package_name}.git"
}

aur_configure() {
    pkgbuild_pkgver=$(cat src/PKGBUILD | grep 'pkgver=' | sed 's|pkgver=||')
    pkgbuild_pkgrel=$(cat src/PKGBUILD | grep 'pkgrel=' | sed 's|pkgrel||')

    cd ..

    sed -i "s|pkgver=.*|pkgver=${pkgbuild_pkgver}|" "${package_name}/PKGBUILD"
    sed -i "s|pkgrel=.*|pkgrel=${pkgbuild_pkgrel}|" "${package_name}/PKGBUILD"
}

aur_push() {
    cd ../"${package_name}"

    git config user.name "Kavplex Bot"
    git config user.email "kavplex@hunterwittenborn.com"

    git add PKGBUILD .SRCINFO

    git commit -m "Updated version in ${pkgbuild_pkgver}-${pkgbuild_pkgrel}"

    git push
}

# Begin script
echo "${known_hosts}" > /root/.ssh/known_hosts
echo "${aur_ssh_key}" > /root/.ssh/AUR

case "${1}" in;
    clone)        aur_clone ;;
    configure)    aur_configure ;;
    push)         aur_push ;;
esac
