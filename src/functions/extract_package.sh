extract_pkg() {
  echo "Extracting ${pkgname}-${controlver}-${arch} package to pkgdir..."
  tar -xf "${pkgname}-${controlver}-${arch}.pkg.tar.zst" -C "${pkgdir}"
}
