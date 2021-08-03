check_relationships() {
    unset temp_${1}
    for i in ${@: 2}; do
        if echo "${i}" | grep -E '<|<=|=|>=|>' &> /dev/null; then

            # Check what kind of dependency relationship symbol is used
            for j in '<=' '>=' '<' '>' '='; do
                if echo "${i}" | grep "${j}" &> /dev/null; then
                    export symbol_type="${j}"
                    # Check if $symbol_type is '<' or '>'
                    if [[ "$(echo "${symbol_type}" | wc -c)" == "2" && "$(echo "${symbol_type}" | grep -Evw '<|>')" == "" ]]; then
                        export old_symbol_type="${j}"
                        export symbol_type+="${j}"
                    else
                        export old_symbol_type="${symbol_type}"
                    fi

                    break
                fi
            done

            # Get values from left and right of symbol (package name and package version)
            export local package_name=$(echo "${i}" | cut -d "${old_symbol_type}" -f 1)
            export local package_version=$(echo "${i}" | cut -d "${old_symbol_type}" -f 2)

            # Add parenthesis if dependency has a relationship
            local dependency_name=$(echo "${package_name}(${symbol_type}${package_version})")
            export temp_${1}+="'${dependency_name}' "

        else
            export temp_${1}+="'${i}' "

        fi

    done

    export ${1}="$(eval echo \${temp_$1})"
}
