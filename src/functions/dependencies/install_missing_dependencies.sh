install_missing_dependencies() {
    if [[ "${#@}" != 0 ]]; then
	#	if (( "${SYNCDEPS}" )); then
			# Get a list of currently installed packages.
#			mapfile -t prev_installed_packages < <(dpkg-query -Wf '${Package}\n' | sort)
			
			# Install the missing deps.
            
            readarray -t array_dependencies < <(perl "${LIBRARY}/binary/missing_apt_dependencies.pl" "${@}")
            
            if (( ${#array_dependencies[@]} )); then
            
			msg "$(gettext "Installing missing dependencies...")"
			if ! sudo "${SUDOARGS[@]}" -- perl "${LIBRARY}/binary/apt_satisfy.pl"  "${APTARGS[@]}"  "${@}" ; then
				error "$(gettext "Failed to install missing dependencies.")"
	#			exit "${E_INSTALL_DEPS_FAILED}"
                return 1
			fi
            fi
	fi
}

# vim: set syntax=bash ts=4 sw=4 expandtab:
