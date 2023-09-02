load ../util/util

@test "correct conflicts - all valid characters" {
    export BATS_SUDO_OVERRIDE=
    run type at
    run type telnet
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild array conflicts 'at>0' 'telnet'
    pkgbuild clean
    makedeb -s --install --no-confirm --allow-downgrades
    [[ "$(cat pkg/testpkg/DEBIAN/control | grep '^Conflicts')" == "Conflicts: at (>> 0), telnet" ]]
    run ! type at
    run ! type telnet
}
