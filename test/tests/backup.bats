load ../util/util

package() {
    mkdir "${pkgdir}/etc/"
    touch "${pkgdir}/etc/config.conf"
}

@test "correct backup" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch 'any'
    pkgbuild array backup '/etc/hi'
    pkgbuild function package
    pkgbuild clean
    makedeb
}

@test "incorrect backup - doesn't start with forward slash" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch 'any'
    pkgbuild array backup 'etc/hi'
    pkgbuild function package
    pkgbuild clean
    run makedeb

    [[ "{status}" != "0" ]]
}
