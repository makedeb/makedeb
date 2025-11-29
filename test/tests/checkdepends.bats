load ../util/util

# bats test_tags=lint
@test "correct checkdepends - all valid characters" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild array checkdepends 'bats>0' 'bash'
    pkgbuild clean
    makedeb -s --no-confirm --allow-downgrades
}

# bats test_tags=lint
@test "correct checkdepends - don't add to 'Depends' in control file" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild array checkdepends 'zsh' 'yash>=0.0.1'
    pkgbuild clean
    makedeb -d
    [[ "$(cat pkg/testpkg/DEBIAN/control | grep 'Depends:')" == "" ]]
}

# bats test_tags=lint
@test "incorrect checkdepends - invalid dependency prefix" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild array checkdepends 'z!bats'
    pkgbuild clean
    run makedeb --lint
    [[ "${status}" == "12" ]]
    [[ "${output}" == "[!] Dependency 'z!bats' under 'checkdepends' contains an invalid prefix: 'z'" ]]
}
