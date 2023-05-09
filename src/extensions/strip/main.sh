post_package=true

main() {
    local file_iter
    local files

    
    if [[ "${MAKEDEB_POST_PACKAGE:+x}" != 'x' ]]; then
        error2 $(printf $(gettext "Don't call '(%s)' from the PKGBUILD.") ${MAKEDEB_EXTENSION_NAME})
        exit 1
    fi
    
    msg2 "Stripping debug symbols from executables..."
    mapfile -t files < <(find "${pkgdir}" -type f)

    for file_iter in "${files[@]}"; do
        if file "${file_iter}" | grep -q 'ELF'; then
            strip "${file_iter}"
        fi
    done
}

# vim: set sw=4 expandtab:
