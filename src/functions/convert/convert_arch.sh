convert_arch() {
    msg "Converting architecure..."

    if [[ "${arch}" == "any" ]]; then
        export makedeb_arch="all"
        export makepkg_arch="any"

    else
        export makepkg_arch="$(uname -m)"

        if [[ "${makepkg_arch}" == "x86_64" ]]; then
            export makedeb_arch="amd64"
        elif [[ "${makepkg_arch}" == "armv7l" ]]; then
            export makedeb_arch="armhf"
        fi
    fi
}
