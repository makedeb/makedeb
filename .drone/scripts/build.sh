#!/usr/bin/env bash
set -e

source "$HOME/.cargo/env"
git fetch
sudo chown 'makedeb:makedeb' ./ -R

# Set up the makedeb repository so the PKGBUILD generator can run properly.
wget -qO - "https://proget.${makedeb_url}/debian-feeds/makedeb.pub" | gpg --dearmor | sudo tee /usr/share/keyrings/makedeb-archive-keyring.gpg 1> /dev/null
echo "deb [signed-by=/usr/share/keyrings/makedeb-archive-keyring.gpg arch=all] https://proget.${makedeb_url}/ makedeb main" | sudo tee /etc/apt/sources.list.d/makedeb.list
sudo apt-get update

# Build makedeb.
cd src/
TARGET=apt RELEASE="${release_type}" LOCAL=1 ../PKGBUILD/pkgbuild.sh > PKGBUILD

if [[ "${BUILD_ARCH:+x}" == 'x' ]]; then
    build_archs=("${BUILD_ARCH}")
else
    build_archs=('amd64' 'i386' 'arm64' 'armhf')
fi

for arch in "${build_archs[@]}"; do
    MAKEDEB_DPKG_ARCHITECTURE="${arch}" ./main.sh -s --no-confirm 1>&3 2>&3
done

mv makedeb*.deb ../