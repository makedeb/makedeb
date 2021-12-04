add_dependency_commas() {
  declare -g depends=("$(echo "${depends[@]}" | sed 's| |, |g')")
  declare -g predepends=("$(echo "${predepends[@]}" | sed 's| |, |g')")
  declare -g recommends=("$(echo "${recommends[@]}" | sed 's| |, |g')")
  declare -g suggests=("$(echo "${suggests[@]}" | sed 's| |, |g')")
  declare -g conflicts=("$(echo "${conflicts[@]}" | sed 's| |, |g')")
  declare -g provides=("$(echo "${provides[@]}" | sed 's| |, |g')")
  declare -g replaces=("$(echo "${replaces[@]}" | sed 's| |, |g')")
  declare -g license=("$(echo "${license[@]}" | sed 's| |, |g')")
}
