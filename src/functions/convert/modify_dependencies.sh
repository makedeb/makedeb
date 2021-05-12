modify_dependencies() {
         # Pipe explanation:
         # 1. Read package databse with 'cat'
         # 2. Append a semicolon(;) to the end of each line
         # 3. Put everything onto one line with 'xargs'
         # 4. Remove everything after first occurance of '# General dependencies'
         # 5. Correct formatting by replacing semicolons(;) with newlines(\n)
  source <(cat "${DATABASE_DIR}"/packages.db | sed 's|$|;|g' | xargs | sed 's|# General dependencies.*||' | sed 's|;|\n|g')

  temp_pkgname=$(echo ${pkgname} | sed 's|-|_|g')
  if [[ $(type -t ${temp_pkgname}) == "function" ]]; then
    echo "Setting package-specific dependencies..."
    "${temp_pkgname}"
    for i in depends optdepends conflicts makedepends checkdepends; do
      "${temp_pkgname}"

      # Remove dependencies
      if [[ $(eval echo \${remove_${i}}) != "" ]]; then
        for j in $(eval echo \${remove_${i}[@]}); do
          eval export new_${i}=$(eval echo \\\${new_${i}//${j}})
        done
      fi

      # Add Dependencies
      if [[ $(eval echo \${add_${i}}) != "" ]]; then
        export new_${i}="$(eval echo "\${new_${i}[@]} \${add_${i}[@]}")"
      fi

    done
    unset "${temp_pkgname}"
  fi
}
