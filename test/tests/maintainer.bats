load ../util/util

# bats test_tags=lint
@test "correct maintainer" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "test"
    pkgbuild array arch any
    pkgbuild clean
    makedeb --lint
}

# bats test_tags=lint
@test "incorrect maintainer - no maintainer" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "test"
    pkgbuild array arch any
    pkgbuild clean
    run makedeb --lint
    [[ "${output}" == "[!] A maintainer must be specified. This will be an error in a future release." ]]
}

# bats test_tags=lint
@test "incorrect maintainer - more than one maintainer" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string maintainer2 'Bar Foo <bar@foo.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "test"
    pkgbuild array arch any
    pkgbuild clean
    run makedeb --lint
    [[ "${output}" == $'[!] More than one maintainer was specified. This will be an error in a future release.\n[!] Falling back to first maintainer \'\'Foo Bar <foo@bar.com>\'\'...' ]]
}
