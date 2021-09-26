# We use this to create an array from a string where it otherwise wouldn't be
# possible, such as in the following:
#
# "${variable}"=('1' '2' '3')
#
# The above fails as variable assignments for arrays cannot be identified by
# variables or quoted strings.
create_array() {
  local target_variable="${1}" \
        array_data=("${@:2}")

  local -n var_ref="${target_variable}"

  var_ref=("${array_data[@]}")

  declare -g "${target_variable}"
  unset -n var_ref
}
