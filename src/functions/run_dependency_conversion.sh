run_dependency_conversion() {
    check_relationships depends      ${depends[@]@Q}
    check_relationships recommends   ${recommends[@]@Q}
	check_relationships suggests     ${suggests[@]@Q}
    check_relationships conflicts    ${conflicts[@]@Q}
    check_relationships provides     ${provides[@]@Q}
    check_relationships replaces     ${replaces[@]@Q}
    check_relationships makedepends  ${makedepends[@]@Q}
    check_relationships checkdepends ${checkdepends[@]@Q}

    # Used to skip adding commas when checking dependencies during building
    [[ "${1}" != "--nocommas" ]] && add_dependency_commas
    convert_relationships_parentheses
}
