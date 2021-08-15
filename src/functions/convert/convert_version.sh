convert_version() {
  local epoch_status=""
  if [[ "${epoch}" != "" ]]; then
    epoch_status="${epoch}:"
  fi
  declare -grx makedeb_package_version="${epoch_status}${pkgver}-${pkgrel}"
}
