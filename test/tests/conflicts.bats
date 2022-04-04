load ../util/util

@test "correct depends - all valid characters" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild array conflicts 'make>0' 'asciidoctor'
    pkgbuild clean
    makedeb -s --install --no-confirm
    [[ "$(cat pkg/testpkg/DEBIAN/control | grep '^Conflicts')" == "Conflicts: make (>> 0), asciidoctor" ]]
    run ! type make
    run ! type asciidoctor
}
