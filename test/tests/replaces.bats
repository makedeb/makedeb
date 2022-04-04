load ../util/util

@test "correct replaces - all valid characters" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild array replaces 'bats>=0' 'bash'
    pkgbuild clean
    makedeb -d

    [[ "$(cat pkg/testpkg/DEBIAN/control | grep '^Replaces:')" == "Replaces: bats (>= 0), bash" ]]
}
