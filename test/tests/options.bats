load ../util/util

@test "correct options - valid options" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild array options '!zipman'
    pkgbuild clean
    makedeb -d
}

@test "incorrect options - invalid options" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild array options '!no_way_this_option_exists'
    pkgbuild clean
    run makedeb -d
    [[ "${status}" == "12" ]]
    [[ "${output}" == "[!] options array contains unknown option '!no_way_this_option_exists'" ]]
}
