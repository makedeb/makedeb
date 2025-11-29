load ../util/util

# bats test_tags=lint
@test "correct prepare()" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild clean
    makedeb --lint
}

# bats test_tags=lint
@test "incorrect prepare() - bad exit code" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    remove_function "prepare"
    echo -e '\nprepare() { false; }' >> PKGBUILD
    pkgbuild clean
    run -4 makedeb -d
}

# bats test_tags=lint
@test "incorrect pkgver() - incorrect syntax for returned version" {
    pkgver() {
        echo "hi me"
    }

    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild function pkgver
    pkgbuild clean
    run -12 makedeb -d
}

# bats test_tags=lint
@test "incorrect package() - missing 'package()' function" {
    build() {
        true
    }

    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild function build
    pkgbuild clean
    run -12 makedeb --lint
}
