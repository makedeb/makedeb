# Maintainer: Hunter Wittenborn <git@hunterwittenborn.me>

pkgname=makedeb
pkgver=1.0.6
pkgrel=1
pkgdesc="Make PKGBUILDs work on Debian-based distros"
arch=('any')
depends=('makepkg')
license=('GPL3')
url="https://github.com/hwittenborn/makedeb"

source=("https://github.com/hwittenborn/makedeb/archive/v${pkgver}.zip")
sha256sums=('SKIP')

package() {
  mkdir -p "${pkgdir}/usr/bin/"
  cp "${srcdir}/makedeb-${pkgver}/makedeb" "${pkgdir}/usr/bin/"
  mkdir -p "${pkgdir}/etc/makedeb"
   cp "${srcdir}/makedeb-${pkgver}/packages.db" "${pkgdir}/etc/makedeb/"
}
