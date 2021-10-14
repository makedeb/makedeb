run_dependency_conversion() {
  check_relationships depends      "${depends[@]}"
  check_relationships predepends   "${predepends[@]}"
  check_relationships recommends   "${recommends[@]}"
  check_relationships suggests     "${suggests[@]}"
  check_relationships conflicts    "${conflicts[@]}"
  check_relationships provides     "${provides[@]}"
  check_relationships replaces     "${replaces[@]}"
  check_relationships makedepends  "${makedepends[@]}"
  check_relationships checkdepends "${checkdepends[@]}"

  # Used to skip adding commas when checking dependencies during building
  [[ "${1}" != "--nocommas" ]] && add_dependency_commas
  convert_relationships_parentheses
}
