post_package=true

main() {
    local manpage
    local manpages

    if [[ "${MAKEDEB_POST_PACKAGE:+x}" != 'x' ]]; then
        error2 "Don't call '${MAKEDEB_EXTENSION_NAME}' from the PKGBUILD."
        exit 1
    fi
    
    if ! [[ -d "${pkgdir}/usr/share/man" ]]; then
        return 0
    fi

    mapfile -t man_pages < <(find "${pkgdir}/usr/share/man" -type f)

    if [[ "${#man_pages[@]}" -gt 0 ]]; then
        msg2 "Compressing man pages..."

        for manpage in "${manpages[@]}"; do
            gzip -9n "${manpage}"
        done
    fi
}

# vim: set sw=4 expandtab:
