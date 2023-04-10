load ../util/util

# bats test_tags=lint
@test "correct depends - all valid characters" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild array depends 'bats>0' 'bash'
    pkgbuild clean
    makedeb --lint
}

@test "correct depends - install missing dependencies" {
    sudo_check
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild array depends 'zsh' 'yash>=0.0.1'
    pkgbuild clean
    makedeb -s --no-confirm --allow-downgrades
}

@test "correct depends - satisfy a build dependency via a provided package" {
    sudo_check
    sudo apt-get satisfy mawk -y
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild array depends 'awk'
    pkgbuild clean
    makedeb
}

# bats test_tags=lint
@test "correct depends - valid dependency prefixes" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild array depends 'p!bats>0' 'bash'
    pkgbuild clean
    run makedeb --print-control

    [[ "$(echo "${output}" | grep '^Pre-Depends')" == "Pre-Depends: bats (>> 0)" ]]
    [[ "$(echo "${output}" | grep '^Depends:')" == "Depends: bash" ]]
}

@test "correct depends - valid dependency prefixes in package()" {
    package() {
        depends=('bats2>0' 'p!bash2')
    }

    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild array depends 'p!bats>0' 'bash'
    pkgbuild function package
    pkgbuild clean
    makedeb -d

    [[ "$(cat pkg/testpkg/DEBIAN/control | grep '^Pre-Depends')" == "Pre-Depends: bash2" ]]
    [[ "$(cat pkg/testpkg/DEBIAN/control | grep '^Depends:')" == "Depends: bats2 (>> 0)" ]]
}

# bats test_tags=lint
@test "correct depends - separate by pipe" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild array depends 'pkg1|pkg2' 'pkg3>=2|pkg4=6'
    pkgbuild clean
    run makedeb --print-control
    [[ "${status}" == 0 ]]
    [[ "$(echo "${output}" | grep '^Depends:')" == 'Depends: pkg1 | pkg2, pkg3 (>= 2) | pkg4 (= 6)' ]]
}

# bats test_tags=lint
@test "correct depends - epoch and pkgrel as version specifier" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild array depends 'pkg1>=1:2.3-4'
    pkgbuild clean
    makedeb --lint
}

# bats test_tags=lint
@test "incorrect depends - invalid dependency prefix" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch all
    pkgbuild array depends 'z!bats'
    pkgbuild clean
    run makedeb --lint
    [[ "${status}" == "12" ]]
    [[ "${output}" == "[!] Dependency 'z!bats' under 'depends' contains an invalid prefix: 'z'" ]]
}
