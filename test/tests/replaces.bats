load ../util/util

# bats test_tags=lint
@test "correct replaces - all valid characters" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild array replaces 'bats>=0' 'bash'
    pkgbuild clean
    run makedeb --print-control

    [[ "$(echo "${output}" | grep '^Replaces:')" == "Replaces: bats (>= 0), bash" ]]
}
