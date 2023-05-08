load ../util/util

@test "correct vcs - missing vcs package" {
    sudo apt purge git -y
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgdesc "package description"
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild array source 'git+https://github.com'
    pkgbuild array sha256sums 'SKIP'
    pkgbuild clean
    run makedeb -d
    [[ "${status}" == "8" ]]
    [[ "${output}" == "[!] Couldn't find the 'git' package needed to handle 'git' sources." ]]
}
