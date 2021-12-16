load ../util/util

@test "correct makedepends - all valid characters" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild array makedepends 'bats>0' 'bash'
    pkgbuild clean
    makedeb -d
}

@test "correct makedepends - install missing dependencies" {
    skip "THIS IS CURRENTLY FAILING DUE TO A BUG IN MAKEDEB."
    sudo_check
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild array makedepends 'zsh' 'yash>=0.0.1'
    pkgbuild clean
    makedeb -s --no-confirm
}

@test "correct makedepends - don't add to 'Depends' in control file" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild array makedepends 'zsh' 'yash>=0.0.1'
    pkgbuild clean
    makedeb -d
    [[ "$(cat pkg/testpkg/DEBIAN/control | grep 'Depends:')" == "" ]]
}

@test "incorrect makedepends - invalid dependency prefix" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild array makedepends 'z!bats'
    pkgbuild clean
    run makedeb -d
    [[ "${status}" == "12" ]]
    [[ "${output}" == "[!] makedepends contains invalid characters: '!'" ]]
}
