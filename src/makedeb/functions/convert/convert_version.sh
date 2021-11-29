convert_version() {
  local epoch_status=""
  if [[ "${epoch}" != "" ]]; then
    epoch_status="${epoch}:"
  fi

  # When in the fakeroot, we source information such as 'pkgver' from the
  # PKGINFO file, which puts epoch, pkgver, and pkgrel under one variable.
  if [[ "${in_fakeroot}" != "true" ]]; then
    declare -gx package_version="${epoch_status}${pkgver}-${pkgrel}"
  else
    declare -gx package_version="${pkgver}"
  fi
}
