get_variables() {
  pkginfo="$(cat .PKGINFO)"

  for i in pkgname pkgver pkgdesc url arch license; do
    export ${i}="$(echo "${pkginfo}" | grep "${i} =" | awk -F ' = ' '{print $2}' | xargs)"
  done

  for i in depends optdepends conflicts; do
    local string=$(echo "${i}" | sed 's|.$||')
    export ${i}="$(echo "${pkginfo}" | grep -w "${string} =" | awk -F ' = ' '{print $2}' | awk -F ':' '{print $1}' | xargs)"
  done
}
