generate_prefix_fields() {
  # depends.
  local depends_keys=("${depends[@]}")
  local depends=()
  local predepends=()
  local string_prefix=""
  local program_name=""
  local string_value=""
  
  for i in "${depends_keys[@]}"; do
    string_prefix="$(echo "${i}" | grep -o '^p!')" || true
    
    if [[ "${string_prefix}" == "p!" ]]; then
      program_name="$(echo "${i}" | sed 's|^p!||')"
      predepends+=("${program_name}")
    else
      depends+=("${i}")
    fi
  done
      
  # optdepends.
  local recommends=()
  local suggests=()

  for i in "${optdepends[@]}"; do
    string_value="${i/:*/}"
    declare string_prefix="$(echo "${string_value}" | grep -Eo '^r!|^s!')"

    if [[ "${string_prefix}" == "" ]]; then
      suggests+=("${i}")
    else
      program_name="$(echo "${string_value}" | sed "s|^${string_prefix}||")"
      if [[ "${string_prefix}" == "r!" ]]; then
        recommends+=("${program_name}")
      elif [[ "${string_prefix}" == "s!" ]]; then
        suggests+=("${program_name}")
      fi
    fi
  done

  # Globally set all variables.
  declare -g depends=("${depends[@]}")
  declare -g predepends=("${predepends[@]}")
  declare -g recommends=("${recommends[@]}")
  declare -g suggests=("${suggests[@]}")
}
