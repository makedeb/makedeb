load ../util/util

@test "correct arch - all allowed characters" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch x86_64
    pkgbuild clean
    makedeb -d
}

@test "incorrect arch - use any with another architecture" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any x86_64
    pkgbuild clean
    run makedeb -d
    [[ "${status}" == "12" ]]
    [[ "${output}" == "[!] Can not use 'any' architecture with other architectures" ]]
}

@test "incorrect arch - unknown architecture" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgdesc "package description"
    pkgbuild string pkgrel 1
    pkgbuild array arch there_is_no_way_this_architecture_exists
    pkgbuild clean
    run makedeb -d
    [[ "${status}" == "12" ]]
    [[ "${output}" == "[!] testpkg is not available for the 'amd64' architecture." ]]
}

@test "allow arch all in sub packages - check architecture field" {
    package_testpkg-doc() {
      arch=('all')
    }

    package_testpkg() {
      echo ''
    }

    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild array pkgname testpkg testpkg-doc
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch amd64
    pkgbuild function package_testpkg
    pkgbuild function package_testpkg-doc
    pkgbuild clean
    makedeb -d
    [[ "$(cat pkg/testpkg-doc/DEBIAN/control | grep '^Architecture')" == "Architecture: all" ]]
}

@test "allow arch all in sub packages - only local changes" {
    package_testpkg-doc() {
      arch=('all')
    }

    package_testpkg() {
      echo ''
    }

    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild array pkgname testpkg testpkg-doc
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch amd64
    pkgbuild function package_testpkg
    pkgbuild function package_testpkg-doc
    pkgbuild clean
    makedeb -d
    [[ "$(cat pkg/testpkg/DEBIAN/control | grep '^Architecture')" == "Architecture: amd64" ]]
}
