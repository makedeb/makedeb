arg_check() {
  while true; do
    case "${1}" in
      --help)              help; exit 0 ;;
      -F | --file | -p)    FILE=${2}; shift;;
      -I | --install)      INSTALL="TRUE" ;;
      -B | --prebuilt)     PREBUILT="TRUE" ;;
      -C | --convert)      package_convert="true" ;;
      -*)                  echo "Unknown option '${1}'"; exit 1 ;;
      "")                  break ;;
    esac
    shift 1
    done
}
