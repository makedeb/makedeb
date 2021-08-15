run_cleanup() {
  # Let's first get the versions of all packages from their .PKGINFO files
  declare -Ag package_versions
  local pkginfo_package_version

  for i in "${pkgname[@]}"; do
    cd "pkg/${i}/"
    pkginfo_package_version="$(get_variables pkgver)"

    declare "pkginfo_package_version[${i}]=${pkginfo_package_version}"
    cd ../../
  done

  # Next, remove lefover build files.
  for i in "${pkgname[@]}"; do
    cd "pkg/${i}/"

    for i in '.BUILDINFO' '.MTREE' '.PKGINFO' '.INSTALL' '.Changelog'; do
      rm -f "${i}"
    done

    cd ../../
  done

  # Lastly, remove the temporary dependency directory used to check build dependencies.
  rm -rf dependency_deb/
}
