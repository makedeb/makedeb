load ../util/util

@test "correct optdepends - all valid characters" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild array optdepends 'bats>0: good shell testing framework' 'bash: king of shell'
    pkgbuild clean
    makedeb -d
}

@test "correct optdepends - install missing dependencies" {
    skip "THIS IS CURRENTLY NOT WORKING DUE TO A BUG IN MAKEDEB."
    sudo_check
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild array optdepends 'zsh: adding a reason so we can see if makedeb strips it before adding it to the control file' 'yash>=0.0.1'
    pkgbuild clean
    makedeb -s --no-confirm
}

@test "correct optdepends - valid dependency prefixes" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild array optdepends 'r!bats>0' 's!bash' 'yash'
    pkgbuild clean
    makedeb -d

    [[ "$(cat pkg/testpkg/DEBIAN/control | grep 'Suggests:')" == "Suggests: bash, yash" ]]
    [[ "$(cat pkg/testpkg/DEBIAN/control | grep 'Recommends:')" == "Recommends: bats (>> 0)" ]]
}

@test "incorrect optdepends - invalid dependency prefix" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch x86_64
    pkgbuild array optdepends 'z!bats'
    pkgbuild clean
    run makedeb -d
    [[ "${status}" == "12" ]]
    [[ "${output}" == "[!] optdepends contains an invalid prefix: 'z!'" ]]
}
