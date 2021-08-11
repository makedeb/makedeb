export_control() {
  if [[ ${@: 2} != "" ]]; then
    echo "${1} ${@: 2}"
  fi
}
