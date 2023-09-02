load ../util/util

# bats test_tags=lint
@test "correct pkgbase - lowercase letters" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgbase testpkg
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild clean
    makedeb --lint
}

# bats test_tags=lint
@test "correct pkgbase - digits and minus sign" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgbase test-123
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild clean
    run makedeb --lint
}

# bats test_tags=lint
@test "correct pkgbase - plus sign" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgbase 'test-1+3'
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild clean
    run makedeb --lint
}

# bats test_tags=lint
@test "correct pkgbase - period" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgbase 'test-1.3'
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild clean
    run makedeb --lint
}

# bats test_tags=lint
@test "incorrect pkgbase - capital letters" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgbase test-Akg
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild clean
    run makedeb --lint
    [[ "${status}" == "12" ]]
    [[ "${output}" == "[!] 'pkgbase' contains capital letters" ]]
}

# bats test_tags=lint
@test "incorrect pkgbase - invalid character" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild string pkgbase 'test-#kg'
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild clean
    run makedeb --lint
    [[ "${status}" == "12" ]]
    [[ "${output}" == "[!] pkgbase contains invalid characters: '#'" ]]
}

# bats test_tags=lint
@test "incorrect pkgbase - array" {
    pkgbuild string maintainer1 'Foo Bar <foo@bar.com>'
    pkgbuild array pkgbase test-pkg test-pkg2
    pkgbuild string pkgname test-pkg
    pkgbuild string pkgver 1.0.0
    pkgbuild string pkgrel 1
    pkgbuild string pkgdesc "package description"
    pkgbuild array arch any
    pkgbuild clean
    run makedeb --lint
    [[ "${status}" == "12" ]]
    [[ "${output}" == '[!] pkgbase should not be an array' ]]
}
