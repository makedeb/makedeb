load ../util/util

@test "install a package with '-i' that contains an epoch" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string epoch 2
    pkgbuild array arch any
    pkgbuild clean
    makedeb -i
}

@test "correct epoch - all allowed characters" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string epoch 200
    pkgbuild array arch any
    pkgbuild clean
    makedeb -d
}

@test "incorrect epoch - negative number" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string epoch '-50'
    pkgbuild array arch any
    pkgbuild clean
    run makedeb -d
    [[ "${status}" == "12" ]]
    [[ "${output}" == '[!] epoch must be an integer, not -50.' ]]
}

@test "incorrect epoch - decimal" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string epoch 20.1
    pkgbuild array arch any
    pkgbuild clean
    run makedeb -d
    [[ "${status}" == "12" ]]
    [[ "${output}" == '[!] epoch must be an integer, not 20.1.' ]]
}

@test "incorrect epoch - letter" {
    skip "THIS IS FAILING DUE TO A BUG IN MAKEDEB."
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string epoch a5
    pkgbuild array arch any
    pkgbuild clean
    run makedeb -d
    [[ "${status}" == "12" ]]
}

# vim: set ts=4 sw=4 expandtab:
