# Author: Hunter Wittenborn <git@hunterwittenborn.me>
# Maintainer: Hunter Wittenborn <git@hunterwittenborn.me>

pkgname=makedeb
pkgver=2.0.5
pkgrel=3
pkgdesc="Make PKGBUILDs work on Debian-based distros"
arch=('any')
depends=('makepkg' 'dpkg-dev' 'binutils' 'file')
license=('GPL3')
url="https://github.com/hwittenborn/makedeb"

source=("makedeb.sh"
        "packages.db")
sha256sums=('SKIP'
	          'SKIP')

package() {
  mkdir -p "${pkgdir}/usr/bin/"
  cp "${srcdir}/makedeb.sh" "${pkgdir}/usr/bin/makedeb"
  mkdir -p "${pkgdir}/etc/makedeb"
   cp "${srcdir}/packages.db" "${pkgdir}/etc/makedeb/"
}
