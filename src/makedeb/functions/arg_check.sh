arg_check() {
  split_args args "${@}"
  set -- "${args[@]}"

  # Declare array for makedeb's arguments. We'll use this variable to store all
  # of makedeb's arguments in the future.
  declare -Ag makedeb_args=()
  declare -ag apt_args=()
  declare -ag makepkg_args=()
  declare -ag pacman_args=()

  # Actual argument check
  if [[ "${target_os}" == "debian" ]]; then
    while [[ "${1}" != "" ]]; do
      case "${1}" in
        -A | --ignore-arch | --ignorearch) declare -g makepkg_args+=("--ignorearch") ;;
        -d | --no-deps | --nodeps)         declare -g skip_dependency_checks="true" ;;
        -F | -p | --file)                  declare -g FILE="${2}"; shift ;;
        -g | --gen-integ | --geninteg)     declare -g makepkg_geninteg="true" ;;
        -h | --help)                       help; exit 0 ;;
        -H | --field)                      export  extra_control_fields+=("${2}"); shift ;;
        -i | --install)                    declare -g INSTALL="TRUE" ;;
        -Q | --no-fields)                  warning "'${1}' has been deprecated, and should not be used." ;;
        -r | --rm-deps | --rmdeps)         declare -g remove_dependencies="true" ;;
        -s | --sync-deps | --syncdeps)     declare -g install_dependencies="true" ;;
        -v | --distro-packages)            warning "'${1}' has been deprecated, and should not be used." ;;
        -V | --version)                    version_info; exit 0 ;;
        --as-deps)                         declare -g makedeb_args["as-deps"]=1 ;;
        --mpr-check | --dur-check)         declare -g mpr_check="true" ;;
        --no-confirm)                      declare -g apt_args+=("--yes") ;;
        --print-control)                   declare -g print_control=1 ;;
        --print-srcinfo | --printsrcinfo)  declare -g makepkg_printsrcinfo="true" ;;
        --skip-pgp-check | --skippgpcheck) declare -g makepkg_args+=("--skippgpcheck") ;;
        --verbose)                         set -x ;;
        -*)                                error "Unknown option '${1}'"; exit 1 ;;
        "")                                break ;;
      esac
      shift 1
    done

  elif [[ "${target_os}" == "arch" ]]; then
    while [[ "${1}" != "" ]]; do
      case "${1}" in
        -A | --ignore-arch | --ignorearch) declare -g makepkg_args+=("--ignorearch") ;;
        -d | --no-deps | --nodeps)         declare -g skip_dependency_checks="true";;
        -F | -p | --file)                  declare -g FILE="${2}"; shift ;;
        -g | --gen-integ | --geninteg)     declare -g makepkg_geninteg="true" ;;
        -h | --help)                       help; exit 0 ;;
        -H | --field)                      export  extra_control_fields+=("${2}"); shift ;;
        -Q | --no-fields)                  warning "'${1}' has been deprecated, and should not be used." ;;
        -r | --rm-deps | --rmdeps)         declare -g remove_dependencies="true" ;;
        -s | --sync-deps | --syncdeps)     declare -g install_dependencies="true" ;;
        -v | --distro-packages)            warning "'${1}' has been deprecated, and should not be used." ;;
        -V | --version)                    version_info; exit 0 ;;
        --mpr-check | --dur-check)         declare -g mpr_check="true" ;;
        --no-confirm)                      declare -g pacman_args+=("--noconfirm") ;;
        --print-control)                   declare -g print_control=1 ;;
        --print-srcinfo | --printsrcinfo)  declare -g makepkg_printsrcinfo="true" ;;
        --skip-pgp-check | --skippgpcheck) declare -g makepkg_args+=("--skippgpcheck") ;;
        --verbose)                         set -x ;;
        -*)                                error "Unknown option '${1}'"; exit 1 ;;
        "")                                break ;;
      esac
      shift 1
    done
  fi

  # Make argument lists read-only.
  declare -gr makedeb_args
  declare -gr apt_args
  declare -gr makepkg_args

  # Argument checks to make sure we didn't request something impossible
  if [[ "${skip_dependency_checks}" == "true" && "${install_dependencies}" == "true" ]]; then
    error "Option '--nodeps' cannot be used with '--syncdeps'."
    error "Aborting..."
    exit 1
  fi

  if [[ "${makepkg_printsrcinfo}" == "true" && "${makepkg_geninteg}" == "true" ]]; then
    error "Option '--printsrcinfo' cannot be used with '--geninteg'."
    error "Aborting..."
    exit 1
  fi

  # Check for "one-liner" options
  if [[ "${makepkg_printsrcinfo}" == "true" ]]; then "${makepkg_package_name}" --format-makedeb --printsrcinfo -p "${FILE:-PKGBUILD}"; exit ${?}; fi
  if [[ "${makepkg_geninteg}" == "true" ]]; then "${makepkg_package_name}" --format-makedeb --geninteg -p "${FILE:-PKGBUILD}"; exit "${?}"; fi
  if [[ "${mpr_check}" == "true" ]]; then mpr_check; exit 0; fi
}
