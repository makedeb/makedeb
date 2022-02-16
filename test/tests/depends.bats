load ../util/util

@test "correct depends - all valid characters" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild array depends 'bats>0' 'bash'
    pkgbuild clean
    makedeb -d
}

@test "correct depends - install missing dependencies" {
    skip "THIS IS CURRENTLY NOT WORKING DUE TO A BUG IN MAKEDEB."
    sudo_check
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild array depends 'zsh' 'yash>=0.0.1'
    pkgbuild clean
    makedeb -s --no-confirm
}

@test "correct depends - satisfy a build dependency via a provided package" {
	sudo_check
	sudo apt-get satisfy mawk -y

	pkgbuild string pkgname testpkg
	pkgbuild string pkgver 1.0.0
	pkgbuild string pkgrel 1
	pkgbuild array arch any
	pkgbuild array depends 'awk'
	pkgbuild clean
	makedeb
}

@test "correct depends - valid dependency prefixes" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild array depends 'p!bats>0' 'bash'
    pkgbuild clean
    makedeb -d

    [[ "$(cat pkg/testpkg/DEBIAN/control | grep '^Pre-Depends')" == "Pre-Depends: bats (>> 0)" ]]
    [[ "$(cat pkg/testpkg/DEBIAN/control | grep '^Depends:')" == "Depends: bash" ]]
}

@test "incorrect depends - invalid dependency prefix" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch x86_64
    pkgbuild array depends 'z!bats'
    pkgbuild clean
    run makedeb -d
    [[ "${status}" == "12" ]]
    [[ "${output}" == "[!] depends contains an invalid prefix: 'z!'" ]]
}

# vim: set syntax=bash ts=4 sw=4 expandtab:
