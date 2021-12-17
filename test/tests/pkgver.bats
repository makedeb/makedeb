load ../util/util

@test "correct pkgver - all allowed characters" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver 1.0.0+alpha
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild clean
    makedeb -d
}

@test "incorrect pkgver - starts with a letter" {
    skip "THIS WON'T RUN CORRECTLY DUE TO A BUG IN MAKEDEB. DISABLE COLOR WHEN USING A NON-TERMINAL PROMPT (AS CAN BE SEEN IN 'src/makepkg/makepkg.sh')"
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver alpha1.0.0
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild clean
    run makedeb -d
    [[ "${status}" == "1" ]]
    [[ "${output}" == '[!] pkgver 'alpha1.0.0' is not allowed to start with a digit.' ]]
}

@test "incorrect pkgver - invalid character" {
    pkgbuild string pkgname testpkg
    pkgbuild string pkgver '1.0.0+al%ha'
    pkgbuild string pkgrel 1
    pkgbuild array arch any
    pkgbuild clean
    run makedeb -d
    [[ "${status}" == '12' ]]
    [[ "${output}" == "[!] pkgver contains invalid characters." ]]
}
