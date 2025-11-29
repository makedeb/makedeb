load ../util/util

@test "correct - build and install a package" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild clean
    makedeb -si --no-confirm --allow-downgrades
}

# bats test_tags=lint
@test "correct - set dependencies from a distro-dependency variable" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild array depends 'gimp'
    pkgbuild array jammy_depends 'krita'
    pkgbuild clean
    makedeb -d
    [[ "$(cat pkg/testpkg/DEBIAN/control | grep 'Depends:')" == "Depends: krita" ]]
}

# bats test_tags=lint
@test "correct - generate SRCINFO and control files" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild clean
    # FIXME Check command output with generated files
    makedeb --print-srcinfo
    makedeb --print-control
}

# bats test_tags=lint
@test "incorrect - set distro-specific sources without distro-specific hashsums" {
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
    makedeb --lint
}
