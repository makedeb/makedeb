convert_relationships() {
    local target_var="${1}"
    local values=("${@:2}")
    local new_values=()
    local matched_rel
    local pkgname
    local pkgver

    for pkg in "${values[@]}"; do
        for rel in '<=' '>=' '=' '>' '<'; do
            if echo "${pkg}" | grep -q "${rel}"; then
                pkgname="$(echo "${pkg}" | sed "s|${rel}.*$||")"
                pkgver="$(echo "${pkg}" | sed "s|^.*${rel}||")"
                
                # Debian control files use '<<' and '>>' for those respective operators.
                if [[ "${rel}" == "<" || "${rel}" == ">" ]]; then
                    matched_rel="${rel}${rel}"
                else
                    matched_rel="${rel}"
                fi
                
                break
            fi
        done

        if [[ "${matched_rel:+x}" == "x" ]]; then
            new_values+=("${pkgname} (${matched_rel} ${pkgver})")
        else
            new_values+=("${pkg}")
        fi

        unset matched_rel
    done
    
    create_array "${target_var}" "${new_values[@]}"
}

# vim: set sw=4 expandtab:
