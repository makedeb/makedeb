convert_version() {
  if [[ "${epoch}" == "" ]]; then
    export controlver="${pkgver}-${pkgrel}"
  else; then
    export controlver="${epoch}:${pkgver}-${pkgrel}"
  fi
}
