add_extra_control_fields() {
    if [[ "${control_fields}" != "" && "${skip_pkgbuild_control_fields}" != "true" ]]; then
        add_extra_control_fields_template "control_fields"
    fi


    if [[ "${extra_control_fields}" != "" ]]; then
        add_extra_control_fields_template "extra_control_fields"
    fi
}
