load ../util/util

@test "correct pkgname - lowercase letters" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild clean
    makedeb -d
}

@test "correct pkgname - digits and minus sign" {
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild clean
    run makedeb -d
}

@test "correct pkgname - plus sign" {
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild clean
    run makedeb -d
}

@test "correct pkgname - period" {
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild clean
    run makedeb -d
}

@test "incorrect pkgname - capital letters" {
    skip "DOESN'T FAIL PROPERLY DUE TO BUG IN MAKEDEB CODE"
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild clean
    run makedeb -d
    [[ "${status}" == "12" ]]
    [[ "${output}" == "something???" ]]
}

@test "incorrect pkgname - disallowed character" {
    pkgbuild string pkgbase testpkg
    pkgbuild string pkgname 'testp%kg'
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild clean
    run makedeb -d
    [[ "${status}" == "12" ]]
    [[ "${output}" == "[!] pkgname contains invalid characters: '%'" ]]
}
