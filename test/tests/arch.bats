load ../util/util

@test "correct arch - all allowed characters" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch x86_64
    pkgbuild clean
    makedeb -d
}

@test "incorrect arch - use any with another architecture" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any x86_64
    pkgbuild clean
    run makedeb -d
    [[ "${status}" == "12" ]]
    [[ "${output}" == "[!] Can not use 'any' architecture with other architectures" ]]
}

@test "incorrect arch - unknown architecture" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch there_is_no_way_this_architecture_exists
    pkgbuild clean
    run makedeb -d
    [[ "${status}" == "12" ]]
    [[ "${output}" == "[!] testpkg is not available for the 'x86_64' architecture." ]]
}
