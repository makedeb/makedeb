setup() {
    cd "${BATS_TEST_DIRNAME}"
    mkdir build_area/
    cp ../files/TEMPLATE.PKGBUILD ./build_area/PKGBUILD
    cd build_area/
}

teardown() {
    cd ../
    rm build_area/ -r
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

sudo_check() {
    if [[ "${BATS_SKIP_SUDO:+x}" == "x" ]]; then
        skip "skipping, as test requires sudo"
    fi
}
