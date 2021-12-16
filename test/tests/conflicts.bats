load ../util/util

@test "correct depends - all valid characters" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild array conflicts 'make>0' 'asciidoctor'
    pkgbuild clean
    makedeb -s --install --no-confirm
    [[ "$(cat pkg/testpkg/DEBIAN/control | grep '^Conflicts')" == "Conflicts: make (>> 0), asciidoctor" ]]
    run ! type make
    run ! type asciidoctor
}
