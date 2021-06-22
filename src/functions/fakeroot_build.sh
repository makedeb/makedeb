fakeroot_build() {
    source "${FILE}"

    if [[ "${PREBUILT}" == "false" ]]; then
        msg "Running makepkg..."
        { makepkg -p "${FILE}" ${makepkg_options}; } | grep -Ev 'Making package|Checking.*dependencies|fakeroot environment|Finished making|\.PKGINFO|\.BUILDINFO|\.MTREE'
        rm *.pkg.tar.zst &> /dev/null

        pkgsetup
        for package in ${pkgname[@]}; do
            unset depends optdepends conflicts provides
            cd "${pkgdir}"/"${package}"

            get_variables
            remove_dependency_description
            run_dependency_conversion
            convert_version
            generate_control

            msg2 "Cleaning up..."
            rm -f ".BUILDINFO"
            rm -f ".MTREE"
            rm -f ".PKGINFO"

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

    else
        mkdir -p "${pkgdir}"/"${package}"/DEBIAN/

        convert_version
        tar -xf "${package}"-"${controlver}"-"${arch}".pkg.tar.zst -C "${pkgdir}"/"${package}" --force-local
        cd "${pkgdir}"/"${package}"

        get_variables
        remove_dependency_description
        run_dependency_conversion
        generate_control

        msg2 "Cleaning up..."
        rm -f ".BUILDINFO"
        rm -f ".MTREE"
        rm -f ".PKGINFO"

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

        msg2 "Building ${package}..."
        dpkg -b "${pkgdir}"/"${package}" >> /dev/null
        mv "${package}".deb ../
        dpkg-name ../"${package}".deb >> /dev/null
        msg2 "Built ${package}"
    fi
}
