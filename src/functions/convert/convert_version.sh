convert_version() {
    [[ "${epoch}" != "" ]] && epoch_status="${epoch}:"

    if [[ "$(type -t pkgver)" == "function" ]]; then
        export built_archive_version="${epoch_status}$(pkgver)-${pkgrel}"
        export pkgbuild_version="${epoch_status}${pkgver}-${pkgrel}"
    else
        export built_archive_version="${epoch_status}${pkgver}-${pkgrel}"
        export pkgbuild_version="${epoch_status}${pkgver}-${pkgrel}"
    fi

}
