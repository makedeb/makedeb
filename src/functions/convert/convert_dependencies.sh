convert_deps() {
  rm_dep_description
  new_depends=${depends[@]}
  new_optdepends=${new_optdepends[@]}
  new_conflicts=${conflicts[@]}
  new_makedepends=${makedepends[@]}
  new_checkdepends=${checkdepends[@]}

  for pkg in $(cat /etc/makedeb/packages.db | sed 's/"//g'); do
    string1=$(echo "${pkg}" | awk -F= '{print $1}')
    string2="$(echo "${pkg}" | awk -F= '{print $2}')"

    new_depends=$(echo ${new_depends[@]} | sed "s/${string1}/${string2}/g")
    new_optdepends=$(echo ${new_optdepends[@]} | sed "s/${string1}/${string2}/g")
    new_conflicts=$(echo ${new_conflicts[@]} | sed "s/${string1}/${string2}/g")
    new_makedepends=$(echo ${new_makedepends[@]} | sed "s/${string1}/${string2}/g")
    new_checkdepends=$(echo ${new_checkdepends[@]} | sed "s/${string1}/${string2}/g")
  done

  new_depends=$(echo ${new_depends[@]} | sed 's/ /, /g')
  new_optdepends=$(echo ${new_optdepends[@]} | sed 's/ /, /g')
  new_conflicts=$(echo ${new_conflicts[@]} | sed 's/ /, /g')

}
