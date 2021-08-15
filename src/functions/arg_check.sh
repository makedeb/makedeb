arg_check() {
  eval set -- ${argument_list[@]@Q}

  # Actual argument check
  if [[ "${target_os}" == "debian" ]]; then
    while [[ "${1}" != "" ]]; do
      case "${1}" in
        -A | --ignore-arch)        declare -g makepkg_options+=("--ignorearch") ;;
        -d | --nodeps)             declare -g skip_dependency_checks="true"; declare makepkg_options+=("--nodeps") ;;
        -F | -p | --file)          declare -g FILE="${2}"; shift ;;
        -h | --help)               help; exit 0 ;;
        -H | --field)              export  extra_control_fields+=("${2}"); shift ;;
        -i | --install)            declare -g INSTALL="TRUE" ;;
        -Q | --no-fields)          warning "'${1}' has been deprecated, and should not be used." ;;
        -r | --rmdeps)             declare -g remove_dependencies="true"; declare makepkg_options+=("--rmdeps") ;;
        -s | --syncdeps)           declare -g install_dependencies="true"; declare makepkg_options+=("--syncdeps") ;;
        -v | --distro-packages)    warning "'${1}' has been deprecated, and should not be used." ;;
        -V | --version)            version_info; exit 0 ;;
        --dur-check)               declare -g dur_check="true" ;;
        --print-control)           declare -g print_control=1 ;;
        --verbose)                 set -x ;;

        -g | --geninteg)           declare -g makepkg_geninteg="true" ;;
        --printsrcinfo)            declare -g makepkg_printsrcinfo="true" ;;
        --skippgpcheck)            declare -g makepkg_options+=("--skippgpcheck") ;;

        -*)                        error "Unknown option '${1}'"; exit 1 ;;
        "")                        break ;;
      esac
      shift 1 || true
    done

  elif [[ "${target_os}" == "arch" ]]; then
    while [[ "${1}" != "" ]]; do
      case "${1}" in
        -A | --ignore-arch)        declare -g makepkg_options+=("--ignorearch") ;;
        -F | -p | --file)          declare -g FILE="${2}"; shift ;;
        -h | --help)               help; exit 0 ;;
        -H | --field)              export  extra_control_fields+=("${2}"); shift ;;
        -Q | --no-fields)          warning "'${1}' has been deprecated, and should not be used." ;;
        -v | --distro-packages)    warning "'${1}' has been deprecated, and should not be used." ;;
        -V | --version)            version_info; exit 0 ;;
        --dur-check)               declare -g dur_check="true" ;;
        --print-control)           declare -g print_control=1 ;;
        --verbose)                 set -x ;;

        -d | --nodeps)             declare -g skip_dependency_checks="true"; declare makepkg_options+=("--nodeps") ;;
        -g | --geninteg)           declare -g makepkg_geninteg="true" ;;
        -r | --rmdeps)             declare -g remove_dependencies="true"; declare makepkg_options+=("--rmdeps") ;;
        -s | --syncdeps)           declare -g install_dependencies="true"; declare makepkg_options+=("--syncdeps") ;;
        --printsrcinfo)            declare -g makepkg_printsrcinfo="true" ;;
        --skippgpcheck)            declare -g makepkg_options+=("--skippgpcheck") ;;

        -*)                        error "Unknown option '${1}'"; exit 1 ;;
        "")                        break ;;
      esac
      shift 1 || true
    done
  fi

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
  if [[ "${dur_check}" == "true" ]]; then dur_check; exit 0; fi
}
