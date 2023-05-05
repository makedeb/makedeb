load ../util/util

# bats test_tags=lint
@test "correct optdepends - all valid characters" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild array optdepends 'bats>0: good shell testing framework' 'bash: king of shell'
    pkgbuild clean
    makedeb --lint
}

@test "correct optdepends - install missing dependencies" {
    sudo_check
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild array optdepends 'sox: adding a reason so we can see if makedeb strips it before adding it to the control file' 'yash>=0.0.1'
    pkgbuild clean
    makedeb -s --no-confirm --allow-downgrades
}

# bats test_tags=lint
@test "correct optdepends - valid dependency prefixes" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild array optdepends 'r!bats>0' 's!bash' 'yash'
    pkgbuild clean
    run makedeb --print-control

    [[ "$(echo "$output" | grep 'Suggests:')" == "Suggests: bash, yash" ]]
    [[ "$(echo "$output" | grep 'Recommends:')" == "Recommends: bats (>> 0)" ]]
}

# bats test_tags=lint
@test "incorrect optdepends - invalid dependency prefix" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch all
    pkgbuild array optdepends 'z!bats'
    pkgbuild clean
    run makedeb --lint
    [[ "${status}" == "12" ]]
    [[ "${output}" == "[!] Dependency 'z!bats' under 'optdepends' contains an invalid prefix: 'z'" ]]
}
