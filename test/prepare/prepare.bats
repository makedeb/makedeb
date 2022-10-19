setup() {
    cd "${BATS_TEST_DIRNAME}"
    export pkgname="${pkgname:-makedeb-alpha}" release_type="${release_type:-alpha}"
}

@test "build makedeb" {
    cd ../../
    .drone/scripts/build.sh
}

@test "install makedeb" {
    cd ../../
    sudo -n DEBIAN_FRONTEND=noninteractive apt-get install "./${pkgname}_"*.deb -y --allow-downgrades -o 'DPkg::Options::=--force-confnew'
}
