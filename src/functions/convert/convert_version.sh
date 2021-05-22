convert_version() {
  if [[ "${epoch}" == "" ]]; then
    export controlver="${pkgver}-${pkgrel}"
  elif [[ "${epoch}" -gt "1" ]]; then
    export controlver="${epoch}:${pkgver}-${pkgrel}"
  fi
}
