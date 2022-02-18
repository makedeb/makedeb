# Setup function run before each test.
setup() {
    cd "${BATS_TEST_DIRNAME}"
    rm -rf build_area/
    mkdir build_area/
    cp ../files/TEMPLATE.PKGBUILD ./build_area/PKGBUILD
    cd build_area/

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

    elif [[ "${cmd}" == "clean" ]]; then
        sed -i 's|^.*$${.*$||g' "${PKGBUILD:-PKGBUILD}"
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
        install) args+=('--allow-downgrades') ;;
    esac

    apt_cmd=("${apt_path}" "${@}" "${args[@]}")

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
