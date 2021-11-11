# This removes comments from optdepends (i.e. 'google-chrome: for power users'
# becomes 'google-chrome').
remove_dependency_description() {
  local temp_optdepends=() optdepends_string

  for i in "${optdepends[@]}"; do
    optdepends_string="$(echo "${i}" | awk -F ':' '{print $1}')"
    temp_optdepends+=("${optdepends_string}")
  done

  optdepends=("${temp_optdepends[@]}")
}
