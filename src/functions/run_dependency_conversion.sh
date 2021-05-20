run_dependency_conversion() {
  if [[ "${package_convert}" == "true" ]]; then
    if ! find "${DATABASE_DIR}"/packages.db &> /dev/null; then
      echo "Couldn't find the database file. Is 'makedeb-db' installed?"
      exit 1
    fi

    convert_deps
    modify_dependencies
  else
    new_depends=${depends[@]}
    new_optdepends=${optdepends[@]}
    new_conflicts=${conflicts[@]}
    new_makedepends=${makedepends[@]}
    new_checkdepends=${checkdepends[@]}
  fi

  check_relationships new_depends      ${new_depends}
  check_relationships new_optdepends   ${new_optdepends}
  check_relationships new_conflicts    ${new_conflicts}
  check_relationships new_makedepends  ${new_makedepends}
  check_relationships new_checkdepends ${new_checkdepends}

  add_dependency_commas
  convert_relationships_parentheses
}
