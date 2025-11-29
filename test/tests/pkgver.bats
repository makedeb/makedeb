load ../util/util

# bats test_tags=lint
@test "correct pkgver - all allowed characters" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0+alpha
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild clean
    makedeb --lint
}

# bats test_tags=lint
@test "incorrect pkgver - starts with a letter" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver alpha1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild clean
    run makedeb --lint
    [[ "${status}" == "12" ]]
    [[ "${output}" == "[!] pkgver doesn't start with a digit." ]]
}

# bats test_tags=lint
@test "incorrect pkgver - invalid character" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver '1.0.0+al#ha'
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild clean
    run makedeb --lint
    [[ "${status}" == '12' ]]
    [[ "${output}" == "[!] pkgver contains invalid characters." ]]
}
