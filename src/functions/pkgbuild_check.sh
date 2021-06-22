pkgbuild_check() {
  for i in pkgname pkgver pkgrel; do
    if [[ "$(eval echo \${${i}})" == "" ]]; then
      error "${i} isn't set"
      exit 1
    fi
  done
}
