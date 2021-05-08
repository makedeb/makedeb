add_dependencies() {
         # Pipe explanation:
         # 1. Read package databse with 'cat'
         # 2. Append a semicolon(;) to the end of each line
         # 3. Put everything onto one line with 'xargs'
         # 4. Remove everything after first occurance of '# General dependencies'
         # 5. Correct formatting by replacing semicolons(;) with newlines(\n)
  source <(cat "${DATABASE_DIR}"/packages.db | sed 's|$|;|g' | xargs | sed 's|# General dependencies.*||' | sed 's|;|\n|g')

  if [[ $(type -t ${pkgname}) == "function" ]]; then
    echo "Adding package-specific dependencies..."
    "${pkgname}"
    for i in depends optdepends conflicts makedepends checkdepends; do
      ${pkgname}
      if [[ $(eval echo \${db_${i}}) != "" ]]; then
        export new_${i}="$(eval echo "\${new_${i}[@]} \${db_${i}[@]}")"
      fi
    done
    unset "${pkgname}"
  fi
}
