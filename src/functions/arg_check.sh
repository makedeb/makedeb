arg_check() {
  while true; do
    case "${1}" in
      -B | --prebuilt)     PREBUILT="TRUE" ;;
      -C | --convert)      package_convert="true" ;;
      -F | --file | -p)    FILE="${2}"; shift;;
      -h | --help)         help; exit 0 ;;
      -i | --install)      INSTALL="TRUE" ;;
      -P | --pkgname)      prebuilt_pkgname="${2}"; shift 1 ;;

      --printsrcinfo)      export makepkg_printsrcinfo="true" ;;

      -*)                  echo "Unknown option '${1}'"; exit 1 ;;
      "")                  break ;;
    esac
    shift 1
    done

    [[ "${makepkg_printsrcinfo}" == "true" ]] && { makepkg --printsrcinfo -p "${FILE:-PKGBUILD}"; exit ${?}; }
}
