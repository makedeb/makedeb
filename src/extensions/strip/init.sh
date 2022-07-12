post_package=true

_strip() {
    local file_iter
    local files

    if [[ "${MAKEDEB_POST_PACKAGE:+x}" != 'x' ]]; then
        error2 "Don't call '${MAKEDEB_EXTENSION_NAME}' from the PKGBUILD."
        exit 1
    fi
    
    msg2 "Stripping debug symbols from executables..."
    mapfile -t files < <(find "${pkgdir}" -type f)

    for file_iter in "${files[@]}"; do
        if file "${file_iter}" | grep -q 'executable'; then
            strip "${file_iter}"
        fi
    done
}

# vim: set sw=4 expandtab:
