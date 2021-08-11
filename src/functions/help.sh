help() {
    if [[ "${target_os}" == "debian" ]]; then
        echo "makedeb (${makedeb_package_version}) - Create Debian archives from PKGBUILDs"
        echo "Usage: makedeb [options]"
        echo
        echo "makedeb takes PKGBUILD files and builds archives installable with APT"
        echo
        echo "Options:"
		echo "  -A, --ignore-arch        Ignore errors about mismatching architectures"
        echo "  -d, --nodeps             Skip all dependency checks"
        echo "  -F, --file, -p           Specify a build file other than 'PKGBUILD'"
        echo "  -h, --help               Show this help menu and exit"
        echo "  -H, --field              Append the resulting control file with custom fields"
        echo "  -i, --install            Automatically install package(s) after building"
        echo "  -Q, --no-fields          Skip adding values from 'control_fields' variable in PKGBUILD to control file"
        echo "  -v, --distro-packages    Source package relationships from distro-specific variables when they exist"
        echo "  -V, --version            Print version information and exit"
		echo "  -r, --rmdeps             Remove installed dependencies after building"
        echo "  -s, --syncdeps           Install missing dependencies"
		echo "  --print-control          Print a generated control file and exit"
        echo "  --verbose                Print (very) detailed logging"
        echo
        echo "The following options can be passed to makepkg:"
		echo "  -g, --geninteg           Generate hashes for source files"
        echo "  --printsrcinfo           Print a generated .SRCINFO file and exit"
        echo "  --skippgpcheck           Do not verify source files against PGP signatures"
        echo
        echo "Report bugs at https://github.com/hwittenborn/makedeb"

    elif [[ "${target_os}" == "arch" ]]; then
        echo "makedeb (${makedeb_package_version}) - Create Debian archives from PKGBUILDs"
        echo "Usage: makedeb [options]"
        echo
        echo "makedeb takes PKGBUILD files and builds archives installable with APT"
        echo
        echo "Options:"
		echo "  -A, --ignore-arch    Ignore errors about mismatching architectures"
        echo "  -F, --file, -p       Specify a build file other than 'PKGBUILD'"
        echo "  -h, --help           Show this help menu and exit"
        echo "  -H, --field          Append the resulting control file with custom fields"
        echo "  -Q, --no-fields      Skip adding values from 'control_fields' variable in PKGBUILD to control file"
        echo "  -V, --version        Print version info and exit"
		echo "  --print-control      Print a generated control file and exit"
        echo "  --verbose            Print (very) detailed logging"
        echo
        echo "The following options can be passed to makepkg:"
        echo "  -d, --nodeps         Skip all dependency checks"
		echo "  -g, --geninteg       Generate hashes for source files"
		echo "  -r, --rmdeps         Remove installed dependencies after building"
        echo "  -s, --syncdeps       Install missing dependencies"
        echo "  --printsrcinfo       Print a generated .SRCINFO file and exit"
        echo "  --skippgpcheck       Do not verify source files against PGP signatures"
        echo
        echo "Report bugs at https://github.com/hwittenborn/makedeb"
    fi
}
