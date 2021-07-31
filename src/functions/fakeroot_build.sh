fakeroot_build() {
    source "${FILE}"

    pkgsetup
    convert_version

	# Used to get pkgver from 'pkginfo_package_versions' string in makedeb.sh
    for package in ${pkgname[@]}; do
        unset depends optdepends conflicts provides replaces license

        cd "pkg/${package}"
        get_variables

        if [[ "${distro_packages}" == "true" ]]; then
            check_distro_dependencies &> /dev/null
        fi

        remove_dependency_description
        run_dependency_conversion
        generate_control
        add_install_scripts

        msg2 "Cleaning up..."
        for i in '.BUILDINFO' '.MTREE' '.PKGINFO' '.INSTALL' '.Changelog'; do
            rm -f "${i}" || true
        done

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

		cd "${package}"
        msg2 "Building ${pkgname}..."

		cd DEBIAN/
		# Run 'eval' with literal quotes around directories in find command so
		# directories containing spaces are still passed as a single argument.
		eval tar -czf ../control.tar.gz $(find ./ -type f | sed "s|.*|'&'|")
		cd ..

		eval tar -czf data.tar.gz $(find ./ -type f | grep -v '^\./DEBIAN' | grep -v 'control\.tar\.gz' | sed "s|.*|'&'|")
		echo "2.0" > debian-binary

		ar r "${package}_${built_deb_version}_${makedeb_arch}.deb" debian-binary control.tar.gz data.tar.gz &> /dev/null

        mv "${package}_${built_deb_version}_${makedeb_arch}.deb" ../../
        msg2 "Built ${pkgname}."

        cd ../..
    done
}
