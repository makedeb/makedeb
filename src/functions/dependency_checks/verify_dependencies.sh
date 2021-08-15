verify_dependencies() {
  if [[ "${#needed_dependencies_temp}" != "0" ]]; then

    # Get bare list of dependency names from control file.
    dependencies=($(cat "dependency_deb/${pkgbase}/DEBIAN/control" | \
                    grep '^Depends: ' | \
                    sed 's|Depends: ||' |
                    sed 's|, |\n|g' | \
                    grep -o '^[^( ]*'))

    # Remove all packages in 'needed_dependencies' that aren't in the list of
    # build dependencies.
    for i in "${needed_dependencies_temp[@]}"; do
      for j in "${dependencies[@]}"; do
        if [[ "${i}" == "${j}" ]]; then
          needed_dependencies+=("${i}")
        fi
      done
    done

    # 'needed_dependencies' is going to be empty if the only packages in it are
    # packages from 'pkgname', so we return if so as to not print an error for
    # no missing dependencies.
    if [[ "${#needed_dependencies}" == "0" ]]; then
      return
    fi

    needed_dependencies_output="$(echo "${needed_dependencies}" | sed 's| |, |g')"

    error "The following build dependencies are missing: ${needed_dependencies_output}"
    exit 1
  fi
}
