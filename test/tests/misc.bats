load ../util/util

@test "correct - build and install a package" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild clean
    makedeb -si --no-confirm
}

@test "correct - set dependencies from a distro-dependency variable" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild array depends 'gimp'
    pkgbuild array focal_depends 'krita'
    pkgbuild clean
    makedeb -d
    set -x
    cat pkg/testpkg/DEBIAN/control
    lsb_release -cs
    set +x
    [[ "$(cat pkg/testpkg/DEBIAN/control | grep 'Depends:')" == "Depends: krita" ]]
}

@test "correct - generate SRCINFO and control files" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild clean
    makedeb --print-srcinfo
    makedeb --print-control
}

@test "incorrect - set distro-specific sources without distro-specific hashsums" {
    skip "THIS ISN'T WORKING DUE TO AN ISSUE IN MAKEDEB."
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild array source 'https://mpr.hunterwittenborn.com'
    pkgbuild array focal_source 'https://proget.hunterwittenborn.com'
    pkgbuild array sha256sums 'SKIP'
    pkgbuild clean
    makedeb -d
}
