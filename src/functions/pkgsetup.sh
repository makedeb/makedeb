pkgsetup() {
  rm -r "${pkgdir}" &> /dev/null
  mkdir -p "${pkgdir}"/DEBIAN/
  touch "${pkgdir}"/DEBIAN/control
}
