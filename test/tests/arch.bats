load ../util/util

# bats test_tags=lint
@test "correct arch - all allowed characters" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch x86_64
    pkgbuild clean
    makedeb --lint
}

# bats test_tags=lint
@test "incorrect arch - use any with another architecture" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any x86_64
    pkgbuild clean
    run -12 makedeb --lint
    [[ "${output}" == "[!] Can not use 'any' architecture with other architectures" ]]
}

# bats test_tags=lint
@test "incorrect arch - unknown architecture" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgdesc "package description"
    pkgbuild string pkgrel 1
    pkgbuild array arch there_is_no_way_this_architecture_exists
    pkgbuild clean
    run -12 makedeb --lint
    [[ "${output}" == "[!] testpkg is not available for the 'amd64' architecture." ]]
}
