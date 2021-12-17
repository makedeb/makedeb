load ../util/util

@test "correct replaces - all valid characters" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild array replaces 'bats>=0' 'bash'
    pkgbuild clean
    makedeb -d

    [[ "$(cat pkg/testpkg/DEBIAN/control | grep '^Replaces:')" == "Replaces: bats (>= 0), bash" ]]
    [[ "$(cat pkg/testpkg/DEBIAN/control | grep '^Breaks:')" == "Breaks: bats (>= 0), bash" ]]
}
