load_extensions() {
    local cur_funcs
    local extdir
    local extension
    local post_package
    post_package_extensions=()

    if [[ "${#extensions[@]}" == 0 ]]; then
        return
    fi

    for extension in "${extensions[@]}"; do
        extdir="${EXTENSIONS_DIR}/${extension}"

        if ! [[ -e "${extdir}" ]]; then
            error2 "$(gettext "Extension '%s' was unable to be found.")" "${extension}"
            exit "${E_INVALID_EXTENSION}"
        elif ! [[ -d "${extdir}" ]]; then
            error2 "$(gettext "Extension '%s' isn't a directory.")" "${extdir}"
            exit "${E_INVALID_EXTENSION}"
        elif ! [[ -f "${extdir}/init.sh" ]]; then
            error2 "$(gettext "Extension '%s' is missing an 'init.sh'.")" "${extension}"
            exit "${E_INVALID_EXTENSION}"
        fi
        
        if ! source "${extdir}/init.sh"; then
            error2 "$(gettext "Failed to load extension '%s'.")" "${extension}"
            exit "${E_INVALID_EXTENSION}"
        fi
        
        # Make sure the script declared it's entrypoint.
        read_env

        if ! in_array "_${extension}" "${env_funcs[@]}"; then
            error2 "$(gettext "Extension '%s' didn't declare an entrypoint.")" "${extension}"
            exit "${E_INVALID_EXTENSION}"
        fi
        
        # Generate a wrapper around the script's entrypoint.
        # We do this so we can handle makedeb-styled message calls to be formatted with a custom prefix.
        # In theory a function can set these values to a custom value, but at that point it's a matter
        # of the function deliberately trying to break makedeb - we're simply trying to provide
        # sane defaults so the extension doesn't have to add themselves.
        source <(
            echo "
                _${extension}() {
                    local MSG_PREFIX=' ${extension}'
                    local MAKEDEB_EXTENSION_NAME='${extension}'
                    local MAKEDEB_EXTENSION_PATH='${EXTENSIONS_DIR}/${extension}'
                    $(type "_${extension}" | sed '1,3d' | tac | sed '1d' | tac)
                }
            "
        )

        if [[ "${post_package:+x}" == 'x' ]]; then
            post_package_extensions+=("${extension}")
            unset post_package
        fi
    done

    declare -r post_package_extensions
}

# vim: set sw=4 expandtab:
