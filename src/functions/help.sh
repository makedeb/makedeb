help() {
    # makedeb section
    echo "makedeb (${package_version}) - Create Debian archives from PKGBUILDs"
    echo "Usage: makedeb [options]"
    echo
    echo "makedeb takes PKGBUILD files and builds archives installable with APT."
    echo
    echo "Options:"
    echo "  Items must be space-separated, i.e. '-i -B'"
    echo
    echo "  -B, --prebuilt - make a Debian package from a prebuilt Arch package; Still requires a build file to be present"
    echo "  -C, --convert - Attempt to convert and modify Arch Linux dependencies in build file to align with Debian"
    if [[ "${target_os}" == "debian" ]]; then
    echo "  -d, --nodeps - Skip all dependency checks"
    fi
    echo "  -F, --file, -p - specify a build file other than 'PKGBUILD'"
    echo "  -h, --help - bring up this help menu"
    if [[ "${target_os}" == "debian" ]]; then
    echo "  -i, --install - automatically install after building"
    fi
    echo "  -P, --pkgname - specify the pkgname for prebuilt packages (--prebuilt) when 'pkgname' is an array"
    if [[ "${target_os}" == "debian" ]]; then
    echo "  -s, --syncdeps - install missing dependencies with APT"
    fi
    echo
    # makepkg section
    echo "The following options can be passed to makepkg:"
    if [[ "${target_os}" == "arch" ]]; then
    echo "  -d, --nodeps - Skip all dependency checks"
    fi
    if [[ "${target_os}" == "arch" ]]; then
    echo "  -s, --syncdeps - install missing dependencies with pacman"
    fi
    echo "  --printsrcinfo - print a generated .SRCINFO file and exit"
    echo "  --skippgpcheck - Do not verify source files against PGP signatures"
    echo
    echo "Report bugs at https://github.com/hwittenborn/makedeb"
}
