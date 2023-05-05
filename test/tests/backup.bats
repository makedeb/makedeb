load ../util/util

package() {
    mkdir "${pkgdir}/etc/"
    touch "${pkgdir}/etc/config.conf"
}

# bats test_tags=lint
@test "correct backup" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch 'any'
    pkgbuild array backup '/etc/hi'
    pkgbuild function package
    pkgbuild clean
    run makedeb
    mapfile -t conffiles < <(cat pkg/testpkg/DEBIAN/conffiles)
    [[ "${#conffiles[@]}" == 1 ]]
    [[ "${conffiles}" == "/etc/hi" ]]
}

# bats test_tags=lint
@test "incorrect backup - doesn't start with forward slash" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch 'any'
    pkgbuild array backup 'etc/hi'
    pkgbuild function package
    pkgbuild clean
    run ! makedeb
}
