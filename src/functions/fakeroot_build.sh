fakeroot_build() {
    source "${FILE}"

    mkdir "${pkgdir}"
    pkgsetup
    convert_version
    for package in ${pkgname[@]}; do
        unset depends optdepends conflicts provides replaces

        tar -xf "${package}-${built_archive_version}-${makepkg_arch}.${package_extension}" -C "${pkgdir}/${package}"
        cd "${pkgdir}/${package}"
        get_variables
        remove_dependency_description
        run_dependency_conversion
        convert_version
        generate_control
        add_install_scripts

        msg2 "Cleaning up..."
        for i in '.BUILDINFO' '.MTREE' '.PKGINFO' '.INSTALL' '.Changelog'; do
            rm -f "${i}" || true
        done

        # Using $pkgver instead of $built_archive_version as $pkgver is pulled from .PKGINFO in the built package
        rm "../../${package}-${pkgver}-${makepkg_arch}.${package_extension}"

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
