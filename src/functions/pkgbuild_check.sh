pkgbuild_check() {

    for i in pkgname pkgver pkgrel; do
        if [[ "$(eval echo \${${i}})" == "" ]]; then
            error "${i} isn't set"
            bad_build_file="true"
        fi
    done

    if [[ "${control_fields}" != "" ]]; then
        export build_file_control_fields="true"

        if ! declare -p control_fields 2> /dev/null | grep -q '^declare \-a'; then
            error 'control_fields should be an array'
            bad_build_file="true"
        fi
    fi

    if [[ "${bad_build_file}" == "true" ]]; then
        exit 1
    fi
}
