arg_check() {
  while true; do
    case "${1}" in
      -B | --prebuilt)     export PREBUILT="TRUE" ;;
      -C | --convert)      export package_convert="true" ;;
      -d | --nodeps)       export skip_dependency_checks="true"; export makepkg_options+=" --nodeps" ;;
      -F | --file | -p)    export FILE="${2}"; shift;;
      -h | --help)         help; exit 0 ;;
      -i | --install)      export INSTALL="TRUE" ;;
      -P | --pkgname)      export prebuilt_pkgname="${2}"; shift 1 ;;
      -s | --syncdeps)     export install_dependencies="true"; export makepkg_options+=" --syncdeps" ;;

      --printsrcinfo)      export makepkg_printsrcinfo="true" ;;
      --skippgpcheck)      export makepkg_options+=" --skippgpcheck" ;;

      -*)                  error "Unknown option '${1}'"; exit 1 ;;
      "")                  break ;;
    esac
    shift 1
    done

    if [[ "${makepkg_printsrcinfo}" == "true" ]]; then makepkg --printsrcinfo -p "${FILE:-PKGBUILD}"; exit ${?}; fi

    # Argument checks to make sure we didn't request something impossible
    if [[ "${skip_dependency_checks}" == "true" && "${install_dependencies}" == "true" ]]; then
      error "Option '--nodeps' cannot be used with '--syncdeps'."
      error "Aborting..."
      exit 1
    fi
}
