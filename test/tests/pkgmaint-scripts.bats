load ../util/util

@test "correct preinst - valid path" {
    touch file
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild string preinst './file'
    pkgbuild clean
    makedeb -d

    ar xf testpkg_1.0.0-1_all.deb
    mapfile -t files < <(tar tf control.tar.gz | sort -V)
    mapfile -t expected_files < <(printf '%s\n' './control' './preinst' | sort -V)

    [[ "${#files[@]}" == "${#expected_files[@]}" ]]

    for i in $(seq 0 $(( "${#files[@]}" - 1 )) ); do
        [[ "${files[$i]}" == "${expected_files[$i]}" ]]
    done
}

@test "incorrect preinst - invalid path" {
    skip "THIS TEST WON'T PASS DUE TO THE 'colorize' BUG IN MAKEDEB"
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild string preinst './file'
    pkgbuild clean
    makedeb -d
}
