convert_version() {
    if [[ "${epoch}" == "" ]]; then
        [[ "${in_fakeroot}" != "true" ]] && export globalver="${pkgver}-${pkgrel}"
        export controlver="${pkgver}-${pkgrel}"
    else
        [[ "${in_fakeroot}" != "true" ]] && export globalver="${epoch}:${pkgver}-${pkgrel}"
        export controlver="${epoch}:${pkgver}-${pkgrel}"
    fi
}
