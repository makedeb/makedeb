get_variables() {
  pkginfo="$(cat .PKGINFO)"

	if [[ "${1}" != "" ]]; then
		echo "${pkginfo}" | grep "${1} =" | cut -d '=' -f 2 | xargs
		return
	fi

  for i in pkgname pkgver pkgdesc url arch license provides replaces; do
    export ${i}="$(echo "${pkginfo}" | grep "${i} =" | cut -d '=' -f 2 | xargs)"
  done

  for i in depends optdepends conflicts; do
    local string=$(echo "${i}" | sed 's|.$||')
    export ${i}="$(echo "${pkginfo}" | grep -w "${string} =" | cut -d '=' -f 2| cut -d ':' -f 1| xargs)"
  done
}
