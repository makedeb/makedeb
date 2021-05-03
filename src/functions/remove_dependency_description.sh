rm_dep_description() {
  NUM=0
  while [[ "${optdepends[$NUM]}" != "" ]]; do
    new_optdepends+=" $(echo ${optdepends[$NUM]} | awk -F: '{print $1}')"
    NUM=$(( ${NUM} + 1 ))
  done
  new_optdepends=$(echo ${new_optdepends[@]} | cut -c1-)

}
