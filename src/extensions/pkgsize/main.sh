post_package=true
main(){
    local no_size
    local control_key
    local control_field
    
    if [[ "${MAKEDEB_POST_PACKAGE:+x}" != 'x' ]]; then
        error2 "Don't call '${MAKEDEB_EXTENSION_NAME}' from the PKGBUILD."
        exit 1
    fi
    
    no_size=true
    
    for control_field in "${MERGED_CONTROL_FIELDS[@]}"; do
		control_key="$(echo "${control_field}" | grep -o '^[^:]*')"
	#	control_value="$(echo "${control_field}" | grep -o '[^:]*$' | sed 's|^ ||')"
        if [[ "${key}" == "Installed-Size" ]]; then
            no_size=false
        fi
	#	write_control_pair "${control_key}" "${control_value}"
	done
    
    if [[ ${no_size} ]]; then
        if [[ -d ${pkgdir} ]]; then
            INSTALLED_SIZE=$(du ${pkgdir} -d 0 | cut -f1)
            MERGED_CONTROL_FIELDS+=("Installed-Size: ${INSTALLED_SIZE}")
            msg2 "Writing control field 'Installed-Size: ${INSTALLED_SIZE}'"
        fi
    fi
}
