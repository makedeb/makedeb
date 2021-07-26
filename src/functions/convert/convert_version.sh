convert_version() {
    [[ "${epoch}" != "" ]] && epoch_status="${epoch}:"

    if [[ "$(type -t pkgver)" == "function" ]]; then
        export built_archive_version="${epoch_status}$(pkgver)-${pkgrel}"
		# We use 'dpkg-name' to generate the filename for the built .deb package.
		# Currently, 'dpkg-name' excludes the epoch from the version, so we
		# exclude it here.
		export built_deb_version="$(pkgver)-${pkgrel}"
        export pkgbuild_version="${epoch_status}${pkgver}-${pkgrel}"
    else
        export built_archive_version="${epoch_status}${pkgver}-${pkgrel}"
		export built_deb_version="${pkgver}-${pkgrel}"
        export pkgbuild_version="${epoch_status}${pkgver}-${pkgrel}"
    fi

}
