pkgbuild_check() {
  for i in pkgname pkgver pkgrel; do
    if [[ "$(eval echo \${${i}})" == "" ]]; then
      echo "${i} isn't set"
      exit 1
    fi
  done
}
