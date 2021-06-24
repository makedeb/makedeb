run_dependency_conversion() {
  if [[ "${package_convert}" == "true" ]]; then

    if ! command -v makedeb-db &> /dev/null; then
      error "Couldn't find the makedeb-db package. Is it installed?"
      exit 1
    fi

    convert_dependencies
    modify_dependencies

  else
    new_depends=${depends[@]}
    new_optdepends=${optdepends[@]}
    new_conflicts=${conflicts[@]}
    new_provides=${provides[@]}
    new_replaces=${replaces[@]}
    new_makedepends=${makedepends[@]}
    new_checkdepends=${checkdepends[@]}
  fi

  check_relationships new_depends      ${new_depends}
  check_relationships new_optdepends   ${new_optdepends}
  check_relationships new_conflicts    ${new_conflicts}
  check_relationships new_provides     ${new_provides}
  check_relationships new_replaces     ${new_replaces}
  check_relationships new_makedepends  ${new_makedepends}
  check_relationships new_checkdepends ${new_checkdepends}

  # Used to skip adding commas when installing dependencies during building
  [[ "${1}" != "--nocommas" ]] && add_dependency_commas
  convert_relationships_parentheses $([[ "${1}" == "--nocommas" ]] && echo "--global")
}
