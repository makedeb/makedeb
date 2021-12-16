load ../util/util

@test "correct source - valid URL" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild array source 'https://mpr.hunterwittenborn.com'
    pkgbuild array sha256sums 'SKIP'
    pkgbuild clean
    makedeb -d
}

@test "correct source - valid hashsum" {
    touch file
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild array source "file://${PWD}/file"
    pkgbuild array sha256sums "$(sha256sum file | awk '{print $1}')"
    pkgbuild clean
    makedeb -d
}

@test "correct source - noextract" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild array source 'makedeb.tar.gz::https://github.com/makedeb/makedeb/archive/refs/tags/v8.5.6-1-stable.tar.gz'
    pkgbuild array sha256sums 'SKIP'
    pkgbuild array noextract 'makedeb.tar.gz'
    pkgbuild clean
    makedeb -d
    [[ "$(find src/ -maxdepth 1 | wc -l)" == "2" ]]
}

@test "incorrect source - invalid URL" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild array source 'https://mpr.hunterwittenborn.corn'
    pkgbuild array sha256sums 'SKIP'
    pkgbuild clean
    run makedeb -d
    [[ "${status}" == "1" ]]
}

@test "incorrect source - missing hashsum" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild array source 'https://mpr.hunterwittenborn.com'
    pkgbuild clean
    run makedeb -d
    [[ "${status}" == "1" ]]
}

@test "incorrect source - incorrect hashsum" {
    touch file
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild array source "file://${PWD}/file"
    pkgbuild array sha256sums 'no_way_this_is_the_hashsum_man'
    pkgbuild clean
    run makedeb -d
    [[ "${status}" == "1" ]]
}
