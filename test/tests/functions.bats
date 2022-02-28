load ../util/util

@test "correct prepare()" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild clean
    makedeb -d
}

@test "incorrect prepare() - bad exit code" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    remove_function "prepare"
    echo -e '\nprepare() { false; }' >> PKGBUILD
    pkgbuild clean
    run makedeb -d
    [[ "${status}" == "4" ]]
}

@test "incorrect pkgver() - incorrect syntax for returned version" {
    pkgver() {
        echo "asdf me"
    }

    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild function pkgver
    pkgbuild clean
    run makedeb -d
    [[ "${status}" == "12" ]]
}

@test "incorrect package() - missing 'package()' function" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    remove_function "package"
    pkgbuild clean
    run makedeb -d
    [[ "${status}" == "12" ]]
}
