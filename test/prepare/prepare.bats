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
    # Annoyingly it looks like 'apt-get' will try to install a package from a repository if the local one we specify can be found in one, so we have to manually install the package with dpkg.
    sudo -n DEBIAN_FRONTEND=noninteractive apt-get install "./${pkgname}_"*.deb -fy --allow-downgrades
    sudo dpkg -i "${pkgname}_"*.deb --force-confnew
}
