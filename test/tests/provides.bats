load ../util/util

# bats test_tags=lint
@test "correct provides - all valid characters" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild array provides 'bats=0' 'bash'
    pkgbuild clean
    run makedeb --print-control

    [[ "$(echo "${output}" | grep '^Provides:')" == "Provides: bats (= 0), bash" ]]
}

# bats test_tags=lint
@test "incorrect provides - uses comparison operators" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild array provides 'bats>=0'
    pkgbuild clean
    run makedeb --lint
    [[ "${status}" == "12" ]]
    [[ "${output}" == "[!] Version restrictor '>=' in 'bats>=0' isn't allowed on 'provides'." ]]
}
