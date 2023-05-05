# shellcheck shell=bash
bats_require_minimum_version 1.9.0

load '../util/bats-support/load.bash'
load '../util/bats-file/load.bash'

lsb_release() {
    echo "jammy"
}
export -f lsb_release

sudo() {
    if [[ "${BATS_SUDO_OVERRIDE}x" != 'x' ]]; then
        echo "sudo: $*"
    else
        /usr/bin/sudo "$@"
    fi
}
export -f sudo

apt-get () {
    if [[ "${BATS_SUDO_OVERRIDE}x" != 'x' ]]; then
        echo "apt-get: $*"
    else
        DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get "$@" -qq
    fi
}
export -f apt-get

# Setup function run before each test.
setup() {
    cd "${BATS_TEST_DIRNAME}" || exit 1

    cp ../files/TEMPLATE.PKGBUILD "${BATS_TEST_TMPDIR}/PKGBUILD"
    cd "${BATS_TEST_TMPDIR}" || exit 1
}

# Utilities to format a templated PKGBUILD.
pkgbuild() {
    cmd="${1}"
    variable="${2}"
    strings=("${@:3}")

    if [[ "${cmd}" == "array" ]]; then
        strings="(${strings[@]@Q})"
        # We have to use a character that isn't use by any strings.
        # For the time being it's a '%', but feel free to change
        # this if you face issues in tests.
        sed -i "s%\$\${${variable}}%${strings}%" "${PKGBUILD:-PKGBUILD}"

    elif [[ "${cmd}" == "string" ]]; then
        strings="${strings[@]}"
        strings="${strings@Q}"
        sed -i "s%\$\${${variable}}%${strings}%" "${PKGBUILD:-PKGBUILD}"

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

# vim: set ts=4 sw=4 expandtab:
