convert_deps() {
  if [[ "${depends}" == "" ]] && \
     [[ "${optdepends}" == "" ]] && \
     [[ "${conflicts}" == "" ]] && \
     [[ "${provides}" == "" ]] && \
     [[ "${makedepends}" == "" ]] && \
     [[ "${optdepends}" == "" ]]; then
    printf ""
  else
    echo "Converting dependencies..."

    new_depends=${depends[@]}
    new_optdepends=${new_optdepends[@]}
    new_conflicts=${conflicts[@]}
    new_provides=${provides[@]}
    new_makedepends=${makedepends[@]}
    new_checkdepends=${checkdepends[@]}

                # Pipe explanation:
                # 1. Read package database with 'cat'
                # 2. Append a semicolon(;) to the end of each line
                # 3. Put everything onto one line with 'xargs'
                # 4. Delete everything until the first occurance of "# General dependencies"
                # 5. Correct formatting by replacing semicolons(;) with newlines(\n)
    for pkg in $(cat "${DATABASE_DIR}"/packages.db | sed 's|$|;|g' | xargs | sed 's|[^:]*\# General dependencies||' | sed 's|;|\n|g'); do
      string1=$(echo "${pkg}" | awk -F= '{print $1}')
      string2="$(echo "${pkg}" | awk -F= '{print $2}')"

      new_depends=$(echo ${new_depends[@]} | sed "s/${string1}/${string2}/g")
      new_optdepends=$(echo ${new_optdepends[@]} | sed "s/${string1}/${string2}/g")
      new_conflicts=$(echo ${new_conflicts[@]} | sed "s/${string1}/${string2}/g")
      new_provides=$(echo ${new_provides[@]} | sed "s/${string1}/${string2}/g")
      new_makedepends=$(echo ${new_makedepends[@]} | sed "s/${string1}/${string2}/g")
      new_checkdepends=$(echo ${new_checkdepends[@]} | sed "s/${string1}/${string2}/g")
    done

  fi
}
