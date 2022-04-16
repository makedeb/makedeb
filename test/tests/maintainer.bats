load ../util/util

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

@test "incorrect maintainer - no maintainer" {
    skip "Awaiting packaging of Bats and Bats libraries on MPR"
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "test"
    pkgbuild array arch any
    pkgbuild clean
    run makedeb --lint
    [[ "${output}" == "[!] A maintainer must be specified." ]]
}

@test "incorrect maintainer - more than one maintainer" {
    skip "Awaiting packaging of Bats and Bats libraries on MPR"
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string maintainer2 'Bar Foo <bar@foo.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "test"
    pkgbuild array arch any
    pkgbuild clean
    run makedeb --lint
    [[ "${output}" == "[!] More than one maintainer was specified." ]]
}
