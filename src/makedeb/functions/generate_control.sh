generate_control() {
    local pkgbuild_location="${1}"
    local output_file="${2}"

    local maintainer="$(cat "${pkgbuild_location}" | grep '\# Maintainer\:' | sed 's/# Maintainer: //' | xargs | sed 's|>|>,|g' | rev | sed 's|,||' | rev)"

    # All field values MUST be passed via '[@]' variable parameters, as
    # export_control() doesn't add the resulting field when '${3}' isn't set
    # (which will happen when the field values aren't equal to anything).
    export_control "Package:"       "${output_file}"  "${pkgname[@]}"
    export_control "Version:"       "${output_file}"  "${package_version[@]}"
    export_control "Description:"   "${output_file}"  "${pkgdesc[@]}"
    export_control "Architecture:"  "${output_file}"  "${MAKEDEB_CARCH}"
    export_control "License:"       "${output_file}"  "${license[@]}"
    export_control "Maintainer:"    "${output_file}"  "${maintainer[@]}"
    export_control "Homepage:"      "${output_file}"  "${url[@]}"
    
    if [[ "${INSTALLED_SIZE:+x}" == "x" ]]; then
        export_control "Installed-Size:" "${output_file}" "${INSTALLED_SIZE}"
    fi

    export_control "Pre-Depends:"   "${output_file}"  "${predepends[@]}"
    export_control "Depends:"       "${output_file}"  "${depends[@]}"
    export_control "Recommends:"    "${output_file}"  "${recommends[@]}"
    export_control "Suggests:"      "${output_file}"  "${suggests[@]}"
    export_control "Conflicts:"     "${output_file}"  "${conflicts[@]}"
    export_control "Provides:"      "${output_file}"  "${provides[@]}"
    export_control "Replaces:"      "${output_file}"  "${replaces[@]}"
    export_control "Breaks:"        "${output_file}"  "${replaces[@]}"

  add_extra_control_fields "${output_file}"
}
