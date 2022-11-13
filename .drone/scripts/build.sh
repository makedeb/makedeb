#!/usr/bin/env bash
#
# This script assumes builds are done on a machine with the amd64 architecture. If using on a different one, usability is not guaranteed.
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
pkgver="$(source PKGBUILD; echo "${pkgver}")"
pkgrel="$(source PKGBUILD; echo "${pkgrel}")"

if [[ "${BUILD_ARCH:+x}" == 'x' ]]; then
    build_archs=("${BUILD_ARCH}")
else
    build_archs=('amd64' 'i386' 'arm64' 'armhf')
fi

# Deps that need to be installed for each architecture. Some of these packages conflict with each other so we do it before the build for each architecture.
amd64_deps=()
i386_deps=('gcc-multilib' 'g++-multilib')
arm64_deps=('gcc-aarch64-linux-gnu' 'g++-aarch64-linux-gnu')
armhf_deps=('gcc-arm-linux-gnueabihf' 'g++-arm-linux-gnueabihf')

for index in "${!build_archs[@]}"; do
    arch="${build_archs[$index]}"

    deps_var="${arch}_deps[@]"
    deps=("${!deps_var}")
    sudo apt-get install "${deps[@]}" -y

    # Ubuntu dropped support for i386 after 18.04.
    if [[ "${arch}" == 'i386' ]] && [[ "$(source /etc/os-release; echo "${ID}")" == 'ubuntu' ]] && [[ "$(source /etc/os-release; echo "${VERSION_ID}" | sed 's|\.||g')" -gt 1804 ]]; then
        continue
    fi

    # Only install the deps of the first architecture. This is dependent on how we declared 'build_archs' above.
    if [[ "${index}" == '0' ]]; then
        MAKEDEB_DPKG_ARCHITECTURE="${arch}" ./main.sh -s --no-confirm
    else
        MAKEDEB_DPKG_ARCHITECTURE="${arch}" ./main.sh -d --no-confirm
    fi
done

for deb in makedeb*.deb; do
    if [[ "${PUBLISH_GH:+x}" == 'x' ]]; then
        no_deb_suffix="$(echo "${deb}" | sed 's|\.deb$||')"
        gh release upload "v${pkgver}-${pkgrel}" "${deb}#${no_deb_suffix}_$(lsb_release -cs)"
    fi

    mv "${deb}" ../
done