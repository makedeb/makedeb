convert_version() {
  if [[ ${epoch} == "" ]]; then
    export controlver="${pkgver}-${pkgrel}"
  else
    export controlver="${epoch}:${pkgver}-${pkgrel}"
  fi
}
