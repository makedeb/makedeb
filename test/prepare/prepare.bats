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
    version="$(cat .data.json | jq -r ".current_pkgver + \"-\" + .current_pkgrel_${release_type}")"

    # Annoyingly it looks like 'apt-get' will try to install a package from a repository if the local one we specify can be found in one, so we have to manually install the package with dpkg.
    sudo -n DEBIAN_FRONTEND=noninteractive apt-get install "./${pkgname}_${version}_all.deb" -fy --allow-downgrades
    sudo dpkg -i "${pkgname}_${version}_all.deb"
}
