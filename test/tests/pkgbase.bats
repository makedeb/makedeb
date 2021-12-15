load ../util/util

@test "correct pkgbase - lowercase letters" {
    pkgbuild string pkgbase testpkg
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild clean
    makedeb -d
}

@test "correct pkgbase - digits and minus sign" {
    pkgbuild string pkgbase test-123
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild clean
    run makedeb -d
}

@test "correct pkgbase - plus sign" {
    pkgbuild string pkgbase 'test-1+3'
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild clean
    run makedeb -d
}

@test "correct pkgbase - period" {
    pkgbuild string pkgbase 'test-1.3'
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild clean
    run makedeb -d
}

@test "incorrect pkgbase - capital letters" {
    skip "DOESN'T FAIL PROPERLY DUE TO BUG IN MAKEDEB CODE"
    pkgbuild string pkgbase test-Akg
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild clean
    run makedeb -d
    [[ "${status}" == "12" ]]
    [[ "${output}" == "something???" ]]
}

@test "incorrect pkgbase - invalid character" {
    pkgbuild string pkgbase 'test-%kg'
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild clean
    run makedeb -d
    [[ "${status}" == "12" ]]
    [[ "${output}" == "[!] pkgbase contains invalid characters: '%'" ]]
}
    
@test "incorrect pkgbase - array" {
    pkgbuild array pkgbase test-pkg test-pkg2
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild clean
    run makedeb -d
    [[ "${status}" == "12" ]]
    [[ "${output}" == '[!] pkgbase should not be an array' ]]
}
