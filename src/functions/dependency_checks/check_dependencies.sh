check_dependencies() {
  declare -g needed_dependencies=() \
             bad_apt_dependencies=()

  # Generate temporary deb file so we can see what dependencies are missing.
  mkdir -p "dependency_deb/${pkgbase}/DEBIAN/"

  pkgname="${pkgbase}" \
    hide_control_output=1 \
    generate_control "./PKGBUILD" "dependency_deb/${pkgbase}/DEBIAN/control"

  cd "dependency_deb/${pkgbase}/"
  build_deb "${pkgbase}"

  # Dry-run install the deb file so we can see what's missing.
  apt_output="$(apt-get install --dry-run "./${pkgbase}_${pkgver}_${makedeb_arch}.deb" 2>&1 || true)"

  cd ../../

  # Process APT's output
  get_apt_output needed_dependencies_temp  "The following NEW packages will be installed"
  get_apt_output bad_apt_dependencies      "The following packages have unmet dependencies"

  # Abort if unmet dependencies were found
  if [[ "${#bad_apt_dependencies}" != "0" ]]; then
    declare -g bad_apt_dependencies=("$(echo "${bad_apt_dependencies[@]}" | \
                                        sed 's|\\n|\n|g' | \
                                        # APT seems to list the name of bad
                                        # packages after the last colon, so we
                                        # remove everything before it.
                                        sed 's|.*: ||g' | \
                                        # Next, find everything up to the last
                                        # ')', or up to the first space when
                                        # that doesn't work.
                                        grep -Eo '^[^)]*)|^[^ ]*' | \
                                        sed 's|[()]||g' | \
                                        sed 's| ||g' | \
                                        tr -t '\n' ' ' | \
                                        sed 's| $||')")

    bad_apt_dependencies_output="$(echo "${bad_apt_dependencies[@]}" | sed 's| |, |g')"

    error "The following build dependencies were unable to be satisfied: ${bad_apt_dependencies_output}"
    exit 1
  fi

  unset bad_apt_dependencies
}
