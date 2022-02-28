# Setup function run before each test.
setup() {
    cd "${BATS_TEST_DIRNAME}"

    rm test_dir/ -rf
    mkdir test_dir/

    cp ../files/TEMPLATE.PKGBUILD test_dir/PKGBUILD
    cd test_dir/

    lsb_release() {
        echo "focal"
    }

    export -f lsb_release
}

# Utilities to format a templated PKGBUILD.
pkgbuild() {
    cmd="${1}"
    variable="${2}"
    strings=("${@:3}")

    if [[ "${cmd}" == "array" ]]; then
        strings="(${strings[@]@Q})"
        sed -i "s|\$\${${variable}}|${strings}|" "${PKGBUILD:-PKGBUILD}"

    elif [[ "${cmd}" == "string" ]]; then
        strings="${strings[@]}"
        strings="${strings@Q}"
        sed -i "s|\$\${${variable}}|${strings}|" "${PKGBUILD:-PKGBUILD}"

    elif [[ "${cmd}" == "function" ]]; then
        if [[ "$(type -t "${variable}")" != 'function' ]]; then
            echo "'${variable}' isn't a function. Not adding to PKGBUILD."
            return 1
        fi

        type "${variable}" | sed 1d | tee -a PKGBUILD 1> /dev/null

    elif [[ "${cmd}" == "clean" ]]; then
        sed -i 's|^.*$${.*$||g' "${PKGBUILD:-PKGBUILD}"

    else
        echo "Invalid command '${cmd}'."
        return 1
    fi
}

remove_function() {
    mapfile -t lines < <(cat "${PKGBUILD:-PKGBUILD}")

    for i in $(seq "${#lines[@]}"); do
        if echo "${lines[$i]}" | grep -q "${1}()"; then
            two_more="$(( "${i}" + 3 ))"
            sed -i "${i},${two_more}d" "${PKGBUILD:-PKGBUILD}"
            break
        fi
    done
}

# Sudo check function.
sudo_check() {
    if [[ "${BATS_SKIP_SUDO:+x}" == "x" ]]; then
        skip "skipping, as test requires sudo"
    fi
}

# APT wrapper for common options that we need.
export apt_path="$(type -pf apt-get)"
export sudo_path="$(type -pf sudo)"

apt() {
    args=()
    cmd="${1}"

    case "${cmd}" in
        install|reinstall|satisfy) args+=('--allow-downgrades') ;;
    esac

    apt_cmd=("${apt_path}" "${args[@]}" "${@}")

    if [[ -n "${SUDO_PREFIX}" ]]; then
        "${sudo_path}" "${apt_cmd[@]}"
    else
        "${apt_cmd[@]}"
    fi
}

apt-get() {
    apt "${@}"
}

# Wrap sudo so we can capture it's APT calls.
sudo() {
    cmd="${1}"

    case "${cmd}" in
        apt|apt-get) SUDO_PREFIX=y apt "${@:2}" ;;
        *) "${sudo_path}" "${@}"
    esac
}

export -f apt apt-get sudo

# vim: set ts=4 sw=4 expandtab:
