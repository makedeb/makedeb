load ../util/util

@test "correct pkgrel - all allowed characters" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild clean
    makedeb -d
}

@test "incorrect pkgrel - letter" {
    skip "THIS WILL FAIL DUE TO THE 'colorize' BUG IN MAKEDEB."
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1a
    pkgbuild array arch any
    pkgbuild clean
    makedeb -d
}

@test "incorrect pkgrel - period" {
    skip "THIS WILL FAIL DUE TO THE 'colorize' BUG IN MAKEDEB."
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1.0
    pkgbuild array arch any
    pkgbuild clean
    makedeb -d
}
