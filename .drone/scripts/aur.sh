#!/usr/bin/env bash
set -e
set -x

[[ "${1}" != "push" ]] && exit 0 # Remove later plz and thx
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
    pkgbuild_pkgrel=$(cat src/PKGBUILD | grep 'pkgrel=' | sed 's|pkgrel=||')

    cd ..

    sed -i "s|pkgver=.*|pkgver=${pkgbuild_pkgver}|" "${package_name}/PKGBUILD"
    sed -i "s|pkgrel=.*|pkgrel=${pkgbuild_pkgrel}|" "${package_name}/PKGBUILD"

    cd "${package_name}"
    sudo -u user 'makepkg --printsrcinfo' | tee .SRCINFO
}

aur_push() {
    # Set up SSH keys and known_hosts
    mkdir -p /root/.ssh/

    echo "${known_hosts}" > /root/.ssh/known_hosts

    echo "${aur_ssh_key}" > /root/.ssh/AUR
    chmod 400 /root/.ssh/AUR

    ssh "aur@${aur_url}" # Remove later plz and thx
    exit 1 # Remove later plz and thx

    pkgbuild_pkgver=$(cat src/PKGBUILD | grep 'pkgver=' | sed 's|pkgver=||')
    pkgbuild_pkgrel=$(cat src/PKGBUILD | grep 'pkgrel=' | sed 's|pkgrel=||')

    cd ../"${package_name}"

    git config user.name "Kavplex Bot"
    git config user.email "kavplex@hunterwittenborn.com"

    git add PKGBUILD .SRCINFO

    git commit -m "Updated version to ${pkgbuild_pkgver}-${pkgbuild_pkgrel}"

    git push "ssh://aur@${aur_url}/${package_name}"
}

# Begin script
useradd user

case "${1}" in
    clone)        aur_clone ;;
    configure)    aur_configure ;;
    push)         aur_push ;;
esac
