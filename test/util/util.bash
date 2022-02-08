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

sudo_check() {
    if [[ "${BATS_SKIP_SUDO:+x}" == "x" ]]; then
        skip "skipping, as test requires sudo"
    fi
}
