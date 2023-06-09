post_package=true
main(){
    local no_size
    local no_main
    local no_multiarch
    local INSTALLED_SIZE
    local control_key
    local control_field
    if [[ "${MAKEDEB_POST_PACKAGE:+x}" != 'x' ]]; then
        error2 $(printf "$(gettext "Don't call '(%s)' from the PKGBUILD.")" ${MAKEDEB_EXTENSION_NAME})
        exit 1
    fi
    
    no_size=true
    no_multiarch=true
    [ -z "${maintainer}" ] && no_main=true || no_main=false
    
    for control_field in "${MERGED_CONTROL_FIELDS[@]}"; do
        arrIN=(${control_field//:/ })
        case "${arrIN[0]}" in
            "Installed-Size") no_size=false;;
            "Multi-Arch") no_multiarch=false;;
            "Maintainer") 
                no_main=false
                maintainer=""
            ;;
            "Description") pkgdesc="";;
            "License") license="";;
            "Homepage") url="";;
            *)
            ;;
        esac
	#	write_control_pair "${control_key}" "${control_value}"
	done
    
    if ${no_multiarch}; then
        if [[ ${multiarch} != "" ]]; then
            MERGED_CONTROL_FIELDS+=("Multi-Arch: ${multiarch}")
        fi
    fi
    
    if ${no_main}; then
        warning2 "$(gettext "A maintainer must be specified." )"
        maintainer=(Unknown)
    fi
    
    
    if ${no_size}; then
        if [[ -d ${pkgdir} ]]; then
            INSTALLED_SIZE=$(du ${pkgdir} -d 0 | cut -f1)
            MERGED_CONTROL_FIELDS+=("Installed-Size: ${INSTALLED_SIZE}")
            msg2 "$(printf "$(gettext "Writing control field '%s'")" "Installed-Size: ${INSTALLED_SIZE}")"
        fi
    fi
}
