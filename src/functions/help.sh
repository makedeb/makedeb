help() {
    if [[ "${target_os}" == "debian" ]]; then
        echo "makedeb (${makedeb_package_version}) - Create Debian archives from PKGBUILDs"
        echo "Usage: makedeb [options]"
        echo
        echo "makedeb takes PKGBUILD files and builds archives installable with APT."
        echo
        echo "Options:"
        echo "  -d, --nodeps             skip all dependency checks"
        echo "  -F, --file, -p           specify a build file other than 'PKGBUILD'"
        echo "  -h, --help               bring up this help menu"
        echo "  -H, --field              append the resulting control file with custom fields"
        echo "  -i, --install            automatically install after building"
        echo "  -v, --distro-packages    source package relationships from distro-specific variables when they exist"
        echo "  -s, --syncdeps           install missing dependencies with APT"
        echo "  --verbose                print (very) detailed logging"
        echo
        echo "The following options can be passed to makepkg:"
        echo "  --printsrcinfo           print a generated .SRCINFO file and exit"
        echo "  --skippgpcheck           Do not verify source files against PGP signatures"
        echo
        echo "Report bugs at https://github.com/hwittenborn/makedeb"

    elif [[ "${target_os}" == "arch" ]]; then
        echo "makedeb (${makedeb_package_version}) - Create Debian archives from PKGBUILDs"
        echo "Usage: makedeb [options]"
        echo
        echo "makedeb takes PKGBUILD files and builds archives installable with APT."
        echo
        echo "Options:"
        echo "  -F, --file, -p    specify a build file other than 'PKGBUILD'"
        echo "  -h, --help        bring up this help menu"
        echo "  -H, --field       append the resulting control file with custom fields"
        echo "  --verbose         print (very) detailed logging"
        echo
        echo "The following options can be passed to makepkg:"
        echo "  -d, --nodeps      Skip all dependency checks"
        echo "  -s, --syncdeps    install missing dependencies with pacman"
        echo "  --printsrcinfo    print a generated .SRCINFO file and exit"
        echo "  --skippgpcheck    Do not verify source files against PGP signatures"
        echo
        echo "Report bugs at https://github.com/hwittenborn/makedeb"
    fi
}
