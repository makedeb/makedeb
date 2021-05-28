convert_relationships_parentheses() {
  # Formats versions to work with Debian control file
  # Adds new_depends for control file (only runs when --nocommas isn't set for run_dependency_conversion())
  for i in $([[ "${1}" == "--global" ]] || echo new_depends) new_optdepends new_conflicts new_provides; do
    export ${i}="$(eval echo \${$i} | sed -E 's/[<>=][<>=]|[<>=]/& /g')"
  done

  # removes specified dependency versions, as packages are passed to APT for build dependencies
  # Adds new_depends for dependency check (only runs when --nocommas *is* set for run_dependency_conversion())
  for i in $([[ "${1}" == "--global" ]] && echo new_depends) new_makedepends new_checkdepends; do
    export ${i}="$(eval echo \${$i} | sed -E 's/[<>=][<>=][0-9.\-]*|[<>=][0-9.\-]*//g')"
  done
}
