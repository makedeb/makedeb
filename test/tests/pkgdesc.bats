load ../util/util

@test "correct pkgdesc - all allowed characters" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "Normal package description: on the package"
    pkgbuild array arch any
    pkgbuild clean
    makedeb -d
}

@test "incorrect pkgdesc - only whitespace" {
    skip "THIS WON'T CURRENT FAIL DUE TO A BUG IN MAKEDEB"
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "     "
    pkgbuild array arch any
    pkgbuild clean
    makedeb -d
}
