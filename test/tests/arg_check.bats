load ../util/util

# bats test_tags=lint
@test "run makedeb with singled short options" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild clean
    makedeb -d -r
}

# bats test_tags=lint
@test "run makedeb with singled long options" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild clean
    makedeb --no-deps --rm-deps
}

# bats test_tags=lint
@test "run makedeb with grouped short options" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild clean
    makedeb -dr
}

# bats test_tags=lint
@test "run makedeb with long options and singled short options" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild clean
    makedeb -d --rm-deps
}

# bats test_tags=lint
@test "run makedeb with long options and grouped short options" {
    sudo_check
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild clean
    makedeb -dr --install --no-confirm
}

# bats test_tags=lint
@test "run makedeb with invalid singled short option" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild clean
    run ! makedeb -d -z
}

# bats test_tags=lint
@test "run makedeb with invalid grouped short option" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild clean
    run ! makedeb -dz
}
