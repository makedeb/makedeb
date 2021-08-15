fakeroot_build() {
  source "${FILE}"

  pkgsetup
  convert_version

  # Used to get pkgver from 'pkginfo_package_versions' string in makedeb.sh
  for package in ${pkgname[@]}; do
    msg "Creating package \"${package}\"..."
    unset depends optdepends conflicts provides replaces license

    cd "pkg/${package}"
    get_variables

    if [[ "${distro_packages}" == "true" ]]; then
      check_distro_dependencies
    fi

    remove_dependency_description
    generate_optdepends_fields
    run_dependency_conversion

    msg2 "Generating control file..."
    generate_control "../../${FILE}" > DEBIAN/control

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
    msg2 "Compressing package..."
    build_deb "${package}"

    mv "${package}_${built_deb_version}_${makedeb_arch}.deb" ../../

    cd ../..
  done

  msg "Leaving fakeroot environment..."
}
