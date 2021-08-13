version_check() {
  if ! echo "${pkgver}" | awk -F '' '{print $1}' | grep -q '[[:digit:]]'; then
    error "pkgver '${pkgver}' is not allowed to start with a digit."
    exit 1
  fi

  if [[ "$(echo "${pkgrel}" | sed 's|[[:digit:]]||g')" != "" ]]; then
    error "pkgrel '${pkgrel}' contains invalid characters."
    error 'pkgrel should be an integer without any decimals.'
    exit 1
  fi
}
