pkgsetup() {
  for i in ${pkgname[@]}; do
    mkdir -p "${pkgdir}"/"${i}"/DEBIAN/
    touch "${pkgdir}"/"${i}"/DEBIAN/control
  done
}
