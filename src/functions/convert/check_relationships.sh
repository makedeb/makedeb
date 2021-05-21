check_relationships() {
  export temp_${1}=""
  for i in ${@: 2}; do
    if echo "${i}" | grep -E '<<|<=|==|>=|>>' &> /dev/null; then

      # Check what kind of dependency relationship symbol is used
      for j in '<<' '<=' "==" ">=" ">>"; do
        if echo "${i}" | grep "${j}" &> /dev/null; then
          export symbol_type="${j}"
          continue
        fi
      done

      # Get values from left and right of symbol (package name and package version)
      export local package_name=$(echo "${i}" | awk -F "${symbol_type}" '{print $1}')
      export local package_version=$(echo "${i}" | awk -F "${symbol_type}" '{print $2}')

      local dependency_name=$(echo " ${package_name}" \("${symbol_type}" "${package_version}"\) | sed 's| ||g')
      export temp_${1}+=" ${dependency_name}"

    else
      export temp_${1}+=" ${i}"

    fi

  done

  export ${1}="$(eval echo \${temp_${1}} | xargs)"
}
