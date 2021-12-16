load ../util/util

@test "run makedeb with singled short options" {
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild clean
    makedeb -d -r
}

@test "run makedeb with singled long options" {
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild clean
    makedeb --no-deps --rm-deps
}

@test "run makedeb with grouped short options" {
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild clean
    makedeb -dr
}

@test "run makedeb with long options and singled short options" {
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild clean
    makedeb -d --rm-deps
}

@test "run makedeb with long options and grouped short options" {
    sudo_check
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild clean
    makedeb -dr --install --no-confirm
}

@test "run makedeb with invalid singled short option" {
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild clean
    run ! makedeb -d -z
}

@test "run makedeb with invalid grouped short option" {
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild clean
    run ! makedeb -dz
}
