convert_arch() {
    msg "Converting architecure..."

    if [[ "${arch}" == "any" ]]; then
        export makedeb_arch="all"
        export makepkg_arch="any"
        export package_extension="pkg.tar.zst"

    else
        export makepkg_arch="$(uname -m)"

        if [[ "${makepkg_arch}" == "x86_64" ]]; then
            export makedeb_arch="amd64"
            export package_extension="pkg.tar.zst"

        elif [[ "${makepkg_arch}" == "armv7l" ]]; then
            export CARCH="armv7h"
            export makepkg_arch="armv7h"
            export makedeb_arch="armhf"
            [[ "${target_os}" == "debian" ]] && export package_extension="pkg.tar.zst"
            [[ "${target_os}" == "arch" ]] && export package_extension="pkg.tar.xz"

        elif [[ "${makepkg_arch}" == "arm64" ]]; then
            export CARCH="aarch64"
            export makepkg_arch="aarch64"
            export makedeb_arch="arm64"
            [[ "${target_os}" == "debian" ]] && export package_extension="pkg.tar.zst"
            [[ "${target_os}" == "arch" ]] && export package_extension="pkg.tar.xz"
        fi
    fi
}
