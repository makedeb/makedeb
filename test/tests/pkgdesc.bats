load ../util/util

@test "correct pkgdesc - all allowed characters" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "Normal package description: on the package"
    pkgbuild array arch any
    pkgbuild clean
    makedeb --lint
}

@test "incorrect pkgdesc - only whitespace" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "     "
    pkgbuild array arch any
    pkgbuild clean
    run makedeb --lint
    [[ "${output}" == "[!] pkgdesc must contain characters other than spaces." ]]
}

@test "incorrect pkgdesc - empty pkgdesc" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc ""
    pkgbuild array arch any
    pkgbuild clean
    run makedeb --lint
    [[ "${output}" == "[!] pkgdesc cannot be empty." ]]
}

@test "incorrect pkgdesc - no pkgdesc" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild clean
    run makedeb --lint
    cat PKGBUILD >&3         
    [[ "${output}" == "[!] pkgdesc must be set." ]]
}
