help() {
	echo "makedeb ${makedeb_package_version}"
	echo "Usage: makedeb [options]"
	echo
	echo "makedeb takes PKGBUILD files and creates archives installable via APT"
	echo
  
	if [[ "${target_os}" == "debian" ]]; then
		echo "Options:"
		echo "  -A, --ignore-arch    Ignore errors about mismatching architectures"
		echo "  -d, --no-deps        Skip all dependency checks"
		echo "  -F, --file, -p       Specify a build file other than 'PKGBUILD'"
		echo "  -g, --gen-integ      Generate hashes for source files"
		echo "  -h, --help           Show this help menu and exit"
		echo "  -H, --field          Append the resulting control file with custom fields"
		echo "  -i, --install        Automatically install package(s) after building"
		echo "  -V, --version        Print version information and exit"
		echo "  -r, --rm-deps        Remove installed dependencies after building"
		echo "  -s, --sync-deps      Install missing dependencies"
		echo "  --print-control      Print a generated control file and exit"
		echo "  --print-srcinfo      Print a generated .SRCINFO file and exit"
		echo "  --skip-pgp-check     Do not verify source files against PGP signatures"
		echo "  --verbose            Print (very) detailed logging"
		echo
		echo "The following options can modify the behavior of APT:"
		echo "  --as-deps             Mark built packages as automatically installed (when using '-i')"
		echo "  --no-confirm          Don't ask before installing packages"

	elif [[ "${target_os}" == "arch" ]]; then
		echo "Options:"
		echo "  -A, --ignore-arch    Ignore errors about mismatching architectures"
		echo "  -d, --no-deps        Skip all dependency checks"
		echo "  -F, --file, -p       Specify a build file other than 'PKGBUILD'"
		echo "  -g, --gen-integ      Generate hashes for source files"
		echo "  -h, --help           Show this help menu and exit"
		echo "  -H, --field          Append the resulting control file with custom fields"
		echo "  -r, --rm-deps        Remove installed dependencies after building"
		echo "  -V, --version        Print version info and exit"
		echo "  -s, --sync-deps      Install missing dependencies"
		echo "  --print-control      Print a generated control file and exit"
		echo "  --verbose            Print (very) detailed logging"
		echo "  --print-src-info     Print a generated .SRCINFO file and exit"
		echo "  --skip-pgp-check     Do not verify source files against PGP signatures"
		echo
		echo "  The following options can modify the behavior of pacman:"
		echo "    --no-confirm       Don't ask before install dependencies"
	fi

	echo
	echo "See makedeb(8) for information on available options and links for obtaining support."
}
