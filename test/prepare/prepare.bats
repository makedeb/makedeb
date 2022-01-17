setup() {
    cd "${BATS_TEST_DIRNAME}"
    export pkgname="${pkgname:-makedeb-alpha}" release_type="${release_type:-alpha}"
}

@test "build makedeb from native-packaged version" {
    cd ../../
    .drone/scripts/build-native.sh
}

@test "install makedeb from native-packaged version" {
    cd ../../
    version="$(cat .data.json | jq -r '.current_pkgver + "-" + .current_pkgrel')"
    sudo -n DEBIAN_FRONTEND=noninteractive apt-get reinstall --allow-downgrades "./${pkgname}_${version}_all.deb" -y
}
