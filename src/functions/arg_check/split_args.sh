# This is used to convert grouped short options (i.e. -asdf) to
# singular short options (i.e. -a -s -d -f)
split_args() {
  declare returned_variable="${1}"
  declare array_values=("${@:2}")
  declare new_arg_list=()

  for i in "${array_values[@]}"; do
    if echo "${i}" | grep '^-[[:alnum:]][[:alnum:]]' &> /dev/null; then
      for i in $(echo "${i}" | sed 's|-||' | sed 's|.|& |g'); do
        declare new_arg_list+=("-${i}")
      done
    else
      declare new_arg_list+=("${i}")
    fi
  done

  create_array "${returned_variable}" "${new_arg_list[@]}"
}
