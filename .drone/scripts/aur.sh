#!/usr/bin/env bash
set -e

# Install packages
echo "Installing needed packages..."
apt update
apt install ssh git gpg -y

wget -qO - "https://${proget_server}/debian-feeds/makedeb.pub" | gpg --dearmor | tee /usr/share/keyrings/makedeb-archive-keyring.gpg &> /dev/null
echo "deb [signed-by=/usr/share/keyrings/makedeb-archive-keyring.gpg arch=all] https://${proget_server} makedeb main" | tee /etc/apt/sources.list.d/makedeb.list

apt update
apt install makepkg -y

# Define functions
aur_clone() {
    cd ..
    git clone "https://${aur_url}/${package_name}.git"
}

aur_configure() {
    pkgbuild_pkgver=$(cat src/PKGBUILD | grep 'pkgver=' | sed 's|pkgver=||')
    pkgbuild_pkgrel=$(cat src/PKGBUILD | grep 'pkgrel=' | sed 's|pkgrel||')

    ls -A
    cd ..
    ls -A

    sed -i "s|pkgver=.*|pkgver=${pkgbuild_pkgver}|" "${package_name}/PKGBUILD"
    sed -i "s|pkgrel=.*|pkgrel=${pkgbuild_pkgrel}|" "${package_name}/PKGBUILD"
}

aur_push() {
    cd ../"${package_name}"

    git config user.name "Kavplex Bot"
    git config user.email "kavplex@hunterwittenborn.com"

    git add PKGBUILD .SRCINFO

    git commit -m "Updated version in ${pkgbuild_pkgver}-${pkgbuild_pkgrel}"

    git push "ssh://aur@${aur_url}/${package_name}"
}

# Begin script
mkdir -p /root/.ssh/
echo "${known_hosts}" > /root/.ssh/known_hosts
echo "${aur_ssh_key}" > /root/.ssh/AUR

case "${1}" in
    clone)        aur_clone ;;
    configure)    aur_configure ;;
    push)         aur_push ;;
esac
