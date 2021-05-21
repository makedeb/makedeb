arg_check() {
  while true; do
    case "${1}" in
      -B | --prebuilt)     PREBUILT="TRUE" ;;
      -C | --convert)      package_convert="true" ;;
      -F | --file | -p)    FILE=${2}; shift;;
      -h | --help)         help; exit 0 ;;
      -I | --install)      INSTALL="TRUE" ;;
      -P | --pkgname)      prebuilt_pkgname="${2}"; shift 1 ;;
      -*)                  echo "Unknown option '${1}'"; exit 1 ;;
      "")                  break ;;
    esac
    shift 1
    done
}
