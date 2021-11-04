# Maintainer: Hunter Wittenborn <hunter@hunterwittenborn.com>
_release=$${release}
_target=$${target}

pkgname=$${pkgname}
pkgver=$${pkgver}
pkgrel=$${pkgrel}
pkgdesc="The modern packaging tool for Debian archives (${_release} release)"
arch=('any')
license=('GPL3')
depends=($${depends})
makedepends=($${makedepends})
conflicts=($${conflicts})
url="https://github.com/makedeb/makedeb"

source=("makedeb::git+${url}/#tag=v${pkgver}-${pkgrel}-${_release}")
sha256sums=('SKIP')

prepare() {
	cd makedeb/
	make prepare PKGVER="${pkgver}" RELEASE="${_release}" TARGET="${_target}"
}

package() {
	cd makedeb/
	make package DESTDIR="${pkgdir}"
}
