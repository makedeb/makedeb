arg_check() {
    # Convert grouped short options into single-character short options
    # (i.e. -ae ==> -a -e)
    for i in ${@}; do
        if [[ "$(echo "${i}" | grep -E '^\-[^-][a-z]')" != "" ]]; then
            number="2"
            letter="$(echo "${i}" | awk -F '' "{print \$$number}")"

            while [[ "${letter}" != "" ]]; do
                argument_list+="-${letter} "

                number="$((${number} + 1 ))"
                letter="$(echo "${i}" | awk -F '' "{print \$$number}")"
            done

        else
            argument_list+="${i} "
        fi
    done

    # Actual argument check
    for i in ${argument_list}; do
        if [[ "${target_os}" == "debian" ]]; then
            case "${i}" in
                -d | --nodeps)             export skip_dependency_checks="true"; export makepkg_options+=" --nodeps" ;;
                -F | -p | --file)          export FILE="${2}"; shift;;
                -h | --help)               help; exit 0 ;;
                -i | --install)            export INSTALL="TRUE" ;;
                -s | --syncdeps)           export install_dependencies="true"; export makepkg_options+=" --syncdeps" ;;
                -v | --distro-packages)    export distro_packages="true" ;;
                --dur-check)               export dur_check="true" ;;

                --printsrcinfo)            export makepkg_printsrcinfo="true" ;;
                --skippgpcheck)            export makepkg_options+=" --skippgpcheck" ;;

                -*)                        error "Unknown option '${1}'"; exit 1 ;;
                "")                        break ;;
            esac
            shift 1 || true

        elif [[ "${target_os}" == "arch" ]]; then
            case "${i}" in
                -F | -p | --file)          export FILE="${2}"; shift;;
                -h | --help)               help; exit 0 ;;
                --dur-check)               export dur_check="true" ;;

                -d | --nodeps)             export skip_dependency_checks="true"; export makepkg_options+=" --nodeps" ;;
                -s | --syncdeps)           export install_dependencies="true"; export makepkg_options+=" --syncdeps" ;;
                --printsrcinfo)            export makepkg_printsrcinfo="true" ;;
                --skippgpcheck)            export makepkg_options+=" --skippgpcheck" ;;

                -*)                        error "Unknown option '${1}'"; exit 1 ;;
                "")                        break ;;
            esac
            shift 1 || true
        fi
    done

    if [[ "${makepkg_printsrcinfo}" == "true" ]]; then makepkg --printsrcinfo -p "${FILE:-PKGBUILD}"; exit ${?}; fi
    if [[ "${dur_check}" == "true" ]]; then dur_check; exit 0; fi

    # Argument checks to make sure we didn't request something impossible
    if [[ "${skip_dependency_checks}" == "true" && "${install_dependencies}" == "true" ]]; then
      error "Option '--nodeps' cannot be used with '--syncdeps'."
      error "Aborting..."
      exit 1
    fi
}
