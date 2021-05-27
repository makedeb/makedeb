add_dependency_commas() {
  new_depends=$(echo ${new_depends[@]} | sed 's/ /, /g')
  new_optdepends=$(echo ${new_optdepends[@]} | sed 's/ /, /g')
  new_conflicts=$(echo ${new_conflicts[@]} | sed 's/ /, /g')
  new_provides=$(echo ${new_provides[@]} | sed 's/ /, /g')
}
