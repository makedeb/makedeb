install_missing_dependencies() {
    if [[ "${#@}" != 0 ]]; then
	#	if (( "${SYNCDEPS}" )); then
			# Get a list of currently installed packages.
#			mapfile -t prev_installed_packages < <(dpkg-query -Wf '${Package}\n' | sort)
			
			# Install the missing deps.
			msg "$(gettext "Installing missing dependencies...")"

			if ! sudo "${SUDOARGS[@]}" -- perl "${LIBRARY}/binary/apt_satisfy.pl"  "${APTARGS[@]}"  "${@}" ; then
				error "$(gettext "Failed to install missing dependencies.")"
	#			exit "${E_INSTALL_DEPS_FAILED}"
                return 1
			fi

			# Get the list of packages that were just installed.
#			mapfile -t cur_installed_packages < <(dpkg-query -Wf '${Package}\n')
#			mapfile -t newly_installed_packages < <(comm -13 --nocheck-order <(printf '%s\n' "${prev_installed_packages[@]}") <(dpkg-query -Wf '${Package}\n' | sort))

#			unset prev_installed_packages cur_installed_packages newly_installed_packages
#		else
#			error "$(gettext "The following build dependencies are missing:")"
#			for dep in "${missing_deps[@]}"; do
#				error2 "${dep}"
#			done

#			args=("${0}" "${CLI_ARGS[@]}" '-s')
#			error "$(gettext "Try running '%s'.")" "${args[*]}"
#			exit "${E_INSTALL_DEPS_FAILED}"
#		fi
	fi
}

# vim: set syntax=bash ts=4 sw=4 expandtab:
