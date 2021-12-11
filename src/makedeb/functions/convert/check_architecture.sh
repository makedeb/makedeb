check_architecture() {
  declare CARCH=""
  declare MAKEDEB_CARCH=""

  if [[ "${arch}" == "any" ]]; then
    declare -grx CARCH="any"
    declare -grx MAKEDEB_CARCH="all"
  else
    declare -grx CARCH="$(uname -m)"
    declare -grx MAKEDEB_CARCH="$(dpkg --print-architecture)"
  fi
}
