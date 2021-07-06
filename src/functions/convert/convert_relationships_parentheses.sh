convert_relationships_parentheses() {
  # Formats versions to work with Debian control file
  # Adds new_depends for control file (only runs when --nocommas isn't set for run_dependency_conversion())
  for i in new_depends new_optdepends new_conflicts new_makedepends new_checkdepends new_provides new_replaces; do
    export ${i}="$(eval echo \${$i} | sed 's|(| (|g' | sed -E 's/[<>=][<>=]|[<>=]/& /g')"
  done
}
