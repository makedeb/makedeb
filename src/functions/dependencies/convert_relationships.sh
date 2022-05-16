convert_relationships() {
    local target_var="${1}"
    local values=("${@:2}")
    local new_values=()
    local pkg
    local pkgs
    local pkg2
    local pkglist=()
    local matched_rel
    local pkgname
    local pkgver

    for pkg in "${values[@]}"; do
        pkglist=()

        mapfile -t pkgs < <(split_dep_by_pipe "${pkg}")

        for pkg2 in "${pkgs[@]}"; do
            for rel in '<=' '>=' '=' '>' '<'; do
                if echo "${pkg2}" | grep -q "${rel}"; then
                    pkgname="$(echo "${pkg2}" | sed "s|${rel}.*$||")"
                    pkgver="$(echo "${pkg2}" | sed "s|^.*${rel}||")"
                
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
                pkglist+=("${pkgname} (${matched_rel} ${pkgver})")
            else
                pkglist+=("${pkg2}")
            fi

            unset matched_rel
        done

        if [[ "${#pkglist[@]}" == 1 ]]; then
            new_values+=("${pkglist[@]}")
        else
            new_values+=("$(printf '%s\n' "${pkglist[@]}" | sed 's/.*/& | /' | tac | rev | sed '1s/ | //' | rev | tac | tr -d '\n')")
        fi
    done

    create_array "${target_var}" "${new_values[@]}"
}

# vim: set sw=4 expandtab:
