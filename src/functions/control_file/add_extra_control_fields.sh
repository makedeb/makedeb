add_extra_control_fields_template() {
    number=0
    control_string="$(eval echo \${${1}[$number]})"

    while [[ "${control_string}" != "" ]]; do

        number="$(( "${number}" + 1 ))"

        control_string_name="$(echo "${control_string}" | grep -o '^[^:]*')"
        control_string_value="$(echo "${control_string}" | sed 's|^[^:]*: ||')"

        if [[ "$(echo "${control_string}" | grep -v ':')" != "" ]]; then
            warning "Control field '${control_string_name}' is invalid. Skipping..."
            control_string="$(eval echo \${${1}[$number]})"
            continue
        fi

        msg2 "Adding field '${control_string_name}' to control file..."
        export_control "${control_string_name}:" "${control_string_value}"

        control_string="$(eval echo \${${1}[$number]})"

    done
}

add_extra_control_fields() {
    if [[ "${build_file_control_fields}" == "true" && "${skip_pkgbuild_fields}" != "true" ]]; then
        add_extra_control_fields_template "control_fields"
    fi


    if [[ "${extra_control_fields}" != "" ]]; then
        add_extra_control_fields_template "extra_control_fields"
    fi
}
