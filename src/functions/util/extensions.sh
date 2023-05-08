load_extensions() {
    local cur_funcs
    local extdir
    local global_env_funcs
    local extension
    local extname
    local post_package
    local msg_extname
    local defined_functions=()
    post_package_extensions=()

    if [[ "${#extensions[@]}" == 0 ]]; then
        return
    fi

    # A list of global functions currently active, we use this to find out which functions
    # have been declared in the function's environment.
    #
    # We have special handling of the 'main' function below, so add it here for easier parsing.
    global_env_funcs=('main' "${env_funcs[@]}")

    for extension in "${extensions[@]}"; do
        extdir="${EXTENSIONS_DIR}/${extension}"
        extname="makedeb-${extension}"
        defined_functions=("${extname}")

        if ! [[ -e "${extdir}" ]]; then
            error2 "$(gettext "Extension '%s' was unable to be found.")" "${extension}"
            exit "${E_INVALID_EXTENSION}"
        elif ! [[ -d "${extdir}" ]]; then
            error2 "$(gettext "Extension '%s' isn't a directory.")" "${extdir}"
            exit "${E_INVALID_EXTENSION}"
        elif ! [[ -f "${extdir}/main.sh" ]]; then
            error2 "$(gettext "Extension '%s' is missing the 'main.sh' file.")" "${extension}"
            exit "${E_INVALID_EXTENSION}"
        fi
        
        if ! source <(
            if ! source "${extdir}/main.sh"; then
                error2 "$(gettext "Failed to load extension '%s'.")" "${extension}"
                exit "${E_INVALID_EXTENSION}"
            fi

            read_env

            if ! in_array main "${env_funcs[@]}"; then
                error2 "$(gettext "Extension '%s' is missing a 'main' function")" "${extension}"
                return 1
            fi

            echo "${post_package:+post_package=1}"
            type main | sed -e 1d -e "2s|^main|${extname}|"

            local func
            for func in "${env_funcs[@]}"; do
                if echo "${func}" | grep -q "^${extension}-"; then
                    local exposed_func="makedeb-${func}"
                    echo "defined_functions+=('${exposed_func}')"
                    type "${func}" | sed -e 1d -e "2s|^${func}|${exposed_func}|"
                fi
            done
        ); then
            error2 "$(gettext "Failed to load extension '%s'.")" "${extension}"
            exit "${E_INVALID_EXTENSION}"
        fi
        
        # Generate a wrapper around the script's entrypoint and other defined functions.
        # We do this so we can handle makedeb-styled message calls to be formatted with a custom prefix.
        # In theory a function can set these values to a custom value, but at that point it's a matter
        # of the function deliberately trying to break makedeb - we're simply trying to provide
        # sane defaults so the extension doesn't have to add themselves.
        for function in "${defined_functions[@]}"; do
            local msg_extname="$(echo "${function}" | sed 's|^makedeb-||')"

            source <(
                echo "
                    ${function}() {
                        local MSG_PREFIX=' ${msg_extname}'
                        local MAKEDEB_EXTENSION_NAME='${extension}'
                        local MAKEDEB_EXTENSION_PATH='${EXTENSIONS_DIR}/${extension}'
                        $(type "${function}" | sed '1,3d' | tac | sed '1d' | tac)
                    }
                "
            )
        done

        if [[ "${post_package:+x}" == 'x' ]]; then
            post_package_extensions+=("${extname}")
            unset post_package
        fi
    done

    declare -r post_package_extensions
}

# vim: set sw=4 expandtab:
