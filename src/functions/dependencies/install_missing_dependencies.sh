install_missing_dependencies() {
    if [[ "${#@}" != 0 ]]; then
	#	if (( "${SYNCDEPS}" )); then
			# Get a list of currently installed packages.
#			mapfile -t prev_installed_packages < <(dpkg-query -Wf '${Package}\n' | sort)
			
			# Install the missing deps.
            
            readarray -t array_dependencies < <(perl "${LIBRARY}/binary/missing_apt_dependencies.pl" "${@}")
            temp=$(mktemp)
            
            if (( ${#array_dependencies[@]} )); then
                msg "$(gettext "Installing missing dependencies...")"
                if ! sudo "${SUDOARGS[@]}" -- bash -c "
                $(typeset -p 'array_dependencies')
                $(typeset -p 'APTARGS')
                $(typeset -p 'temp')
                old_deps=\$(dpkg-query -Wf '\${Package}\\n')
                
                if ! apt-get satisfy \"\${APTARGS[@]}\"  \"\${array_dependencies[@]}\" ; then
                    return 1
                fi
                
                cur_deps=\$(dpkg-query -Wf '\${Package}\\n')
                
                echo \"\$old_deps\" \"\$old_deps\" \"\$cur_deps\" | sort | uniq -u > \"\$temp\"
                
                "  ; then 
                
                    error "$(gettext "Failed to install missing dependencies.")"
	#			    exit "${E_INSTALL_DEPS_FAILED}"
                    return 1
                else 
                    readarray -t array_dependencies_installed < <(cat "$temp")
                    rm "$temp"
                fi
            fi
	fi
}

# vim: set syntax=bash ts=4 sw=4 expandtab:
