arg_check() {
    eval set -- ${argument_list[@]@Q}

    # Actual argument check
    if [[ "${target_os}" == "debian" ]]; then
        while [[ "${1}" != "" ]]; do
            case "${1}" in
				-A | --ignore-arch)        export makepkg_options+=" --ignorearch" ;;
                -d | --nodeps)             export skip_dependency_checks="true"; export makepkg_options+=" --nodeps" ;;
                -F | -p | --file)          export FILE="${2}"; shift ;;
                -h | --help)               help; exit 0 ;;
                -H | --field)              export extra_control_fields+=("${2}"); shift ;;
                -i | --install)            export INSTALL="TRUE" ;;
                -Q | --no-fields)          export skip_pkgbuild_control_fields="true" ;;
				-r | --rmdeps)             export remove_dependencies="true"; export makepkg_options+=" --rmdeps" ;;
                -s | --syncdeps)           export install_dependencies="true"; export makepkg_options+=" --syncdeps" ;;
                -v | --distro-packages)    export distro_packages="true" ;;
                -V | --version)            version_info; exit 0 ;;
                --dur-check)               export dur_check="true" ;;
                --verbose)                 set -x ;;

				-g | --geninteg)           export makepkg_geninteg="true" ;;
                --printsrcinfo)            export makepkg_printsrcinfo="true" ;;
                --skippgpcheck)            export makepkg_options+=" --skippgpcheck" ;;

                -*)                        error "Unknown option '${1}'"; exit 1 ;;
                "")                        break ;;
            esac
            shift 1 || true
        done

    elif [[ "${target_os}" == "arch" ]]; then
        while [[ "${1}" != "" ]]; do
            case "${1}" in
				-A | --ignore-arch)        export makepkg_options+=" --ignorearch" ;;
                -F | -p | --file)          export FILE="${2}"; shift ;;
                -h | --help)               help; exit 0 ;;
                -Q | --no-fields)          export skip_pkgbuild_control_fields="true" ;;
                -V | --version)            version_info; exit 0 ;;
                --dur-check)               export dur_check="true" ;;
                --verbose)                 set -x ;;

                -d | --nodeps)             export skip_dependency_checks="true"; export makepkg_options+=" --nodeps" ;;
				-g | --geninteg)           export makepkg_geninteg="true" ;;
				-r | --rmdeps)             export remove_dependencies="true"; export makepkg_options+=" --rmdeps" ;;
                -s | --syncdeps)           export install_dependencies="true"; export makepkg_options+=" --syncdeps" ;;
                --printsrcinfo)            export makepkg_printsrcinfo="true" ;;
                --skippgpcheck)            export makepkg_options+=" --skippgpcheck" ;;

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
    if [[ "${makepkg_printsrcinfo}" == "true" ]]; then makepkg --printsrcinfo -p "${FILE:-PKGBUILD}"; exit ${?}; fi
	if [[ "${makepkg_geninteg}" == "true" ]]; then makepkg --geninteg -p "${FILE:-PKGBUILD}"; exit "${?}"; fi
    if [[ "${dur_check}" == "true" ]]; then dur_check; exit 0; fi

}
