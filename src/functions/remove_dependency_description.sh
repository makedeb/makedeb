remove_dependency_description() {
  NUM=0
  while [[ "${optdepends[$NUM]}" != "" ]]; do
    local temp_new_optdepends+=" $(echo ${optdepends[$NUM]} | awk -F: '{print $1}')"
    NUM=$(( ${NUM} + 1 ))
  done
  new_optdepends=$(echo ${temp_new_optdepends[@]} | xargs)

}
