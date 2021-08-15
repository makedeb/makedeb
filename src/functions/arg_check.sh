arg_check() {
  eval set -- ${argument_list[@]@Q}

  # Actual argument check
  if [[ "${target_os}" == "debian" ]]; then
    while [[ "${1}" != "" ]]; do
      case "${1}" in
        -A | --ignore-arch)        declare makepkg_options+=("--ignorearch") ;;
        -d | --nodeps)             declare skip_dependency_checks="true"; declare makepkg_options+=("--nodeps") ;;
        -F | -p | --file)          declare FILE="${2}"; shift ;;
        -h | --help)               help; exit 0 ;;
        -H | --field)              export  extra_control_fields+=("${2}"); shift ;;
        -i | --install)            declare INSTALL="TRUE" ;;
        -Q | --no-fields)          export  skip_pkgbuild_control_fields="true" ;;
        -r | --rmdeps)             declare remove_dependencies="true"; declare makepkg_options+=("--rmdeps") ;;
        -s | --syncdeps)           declare install_dependencies="true"; declare makepkg_options+=("--syncdeps") ;;
        -v | --distro-packages)    export  distro_packages="true"; declare makepkg_options+=("--distrovars") ;;
        -V | --version)            version_info; exit 0 ;;
        --dur-check)               declare dur_check="true" ;;
        --print-control)           declare print_control=1 ;;
        --verbose)                 set -x ;;

        -g | --geninteg)           declare makepkg_geninteg="true" ;;
        --printsrcinfo)            declare makepkg_printsrcinfo="true" ;;
        --skippgpcheck)            declare makepkg_options+=("--skippgpcheck") ;;

        -*)                        error "Unknown option '${1}'"; exit 1 ;;
        "")                        break ;;
      esac
      shift 1 || true
    done

  elif [[ "${target_os}" == "arch" ]]; then
    while [[ "${1}" != "" ]]; do
      case "${1}" in
        -A | --ignore-arch)        declare makepkg_options+=("--ignorearch") ;;
        -F | -p | --file)          declare FILE="${2}"; shift ;;
        -h | --help)               help; exit 0 ;;
        -H | --field)              export  extra_control_fields+=("${2}"); shift ;;
        -Q | --no-fields)          export  skip_pkgbuild_control_fields="true" ;;
        -V | --version)            version_info; exit 0 ;;
        --dur-check)               declare dur_check="true" ;;
        --print-control)           declare print_control=1 ;;
        --verbose)                 set -x ;;

        -d | --nodeps)             declare skip_dependency_checks="true"; declare makepkg_options+=("--nodeps") ;;
        -g | --geninteg)           declare makepkg_geninteg="true" ;;
        -r | --rmdeps)             declare remove_dependencies="true"; declare makepkg_options+=("--rmdeps") ;;
        -s | --syncdeps)           declare install_dependencies="true"; declare makepkg_options+=("--syncdeps") ;;
        --printsrcinfo)            declare makepkg_printsrcinfo="true" ;;
        --skippgpcheck)            declare makepkg_options+=("--skippgpcheck") ;;

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
