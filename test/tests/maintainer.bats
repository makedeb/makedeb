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
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "test"
    pkgbuild array arch any
    pkgbuild clean
    run makedeb --lint
    echo "${output[@]}" >&3
    [[ "${output}" == "[!] A maintainer must be specified." ]]
}

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
    [[ "${output}" == "[!] More than one maintainer was specified." ]]
}
