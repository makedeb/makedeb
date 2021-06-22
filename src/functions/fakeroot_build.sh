fakeroot_build() {
    source "${FILE}"

    mkdir "${pkgdir}"
    pkgsetup
    for package in ${pkgname[@]}; do
        unset depends optdepends conflicts provides

        tar -xf "${package}-${built_package_version}-${makepkg_arch}.pkg.tar.zst" -C "${pkgdir}/${package}"
        cd "${pkgdir}/${package}"
        get_variables
        remove_dependency_description
        run_dependency_conversion
        convert_version
        generate_control

        msg2 "Cleaning up..."
        for i in '.BUILDINFO' '.MTREE' '.PKGINFO' '.INSTALL' '.Changelog'; do
            rm -f "${i}" || true
        done
        
        # Using $pkgver instead of $built_package_version as $pkgver is pulled from .PKGINFO in the built package
        rm "../../${package}-${pkgver}-${makepkg_arch}.pkg.tar.zst"

        field() {
            cat "DEBIAN/control" | grep "${1}:" | awk -F": " '{print $2}'
        }

        debname=$( echo "$(field Package)_$(field Version)_$(field Architecture)" )
        debname_install+=" ${debname}"

        cd ..
        if find ../"${debname}.deb" &> /dev/null; then
            warning "Built package detected. Removing..."
            rm ../"${debname}.deb"
        fi

        msg2 "Building ${pkgname}..."
        dpkg -b "${pkgdir}"/"${package}" >> /dev/null
        mv "${package}".deb ../
        dpkg-name ../"${package}".deb >> /dev/null
        msg2 "Built ${pkgname}."

        cd ..
    done
}
