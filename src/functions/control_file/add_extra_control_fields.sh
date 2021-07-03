add_extra_control_fields() {

    if [[ "${extra_control_fields}" != "" ]]; then

        number=0
        control_string="$(eval echo \${extra_control_fields[$number]})"

        while [[ "${control_string}" != "" ]]; do

            number="$(( "${number}" + 1 ))"

            control_string_name="$(echo "${control_string}" | grep -o '^[^:]*')"
            control_string_value="$(echo "${control_string}" | sed 's|^[^:]*: ||')"

            if [[ "$(echo "${control_string}" | grep -v ':')" != "" ]]; then
                warning "Control field '${control_string_name}' is invalid. Skipping..."
                control_string="$(eval echo \${extra_control_fields[$number]})"
                continue
            fi

            msg2 "Adding field '${control_string_name}' to control file..."
            export_control "${control_string_name}:" "${control_string_value}"

            control_string="$(eval echo \${extra_control_fields[$number]})"

        done
    fi
}
