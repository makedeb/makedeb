convert_version() {
  local epoch_status=""
  [[ "${epoch}" != "" ]] && epoch_status="${epoch}:"
  declare -grx makedeb_package_version="${epoch_status}${pkgver}-${pkgrel}"
}
