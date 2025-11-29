load ../util/util

@test "install a package with '-i' that contains an epoch" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string epoch 2
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild clean
    makedeb -i --allow-downgrades
}

# bats test_tags=lint
@test "correct epoch - all allowed characters" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string epoch 200
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild clean
    makedeb --lint
}

# bats test_tags=lint
@test "incorrect epoch - negative number" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string epoch '-50'
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild clean
    run makedeb --lint
    [[ "${status}" == "12" ]]
    [[ "${output}" == '[!] epoch must be an integer, not -50.' ]]
}

# bats test_tags=lint
@test "incorrect epoch - decimal" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string epoch 20.1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild clean
    run makedeb --lint
    [[ "${status}" == "12" ]]
    [[ "${output}" == '[!] epoch must be an integer, not 20.1.' ]]
}

# bats test_tags=lint
@test "incorrect epoch - letter" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string epoch a5
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild clean
    run makedeb --lint
    [[ "${status}" == "12" ]]
}

# vim: set ts=4 sw=4 expandtab:
