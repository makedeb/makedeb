# Maintainer: Hunter Wittenborn <hunter@hunterwittenborn.com>
_release=$${release}
_target=$${target}

pkgname=$${pkgname}
pkgver=$${pkgver}
pkgrel=$${pkgrel}
pkgdesc="A simplicity-focused packaging tool for Debian archives (${_release} release)"
arch=('all')
license=('GPL3')
depends=($${depends})
makedepends=($${makedepends})
conflicts=($${conflicts})
provides=($${provides})
replaces=($${replaces})
url="https://github.com/makedeb/makedeb"

source=("makedeb::git+${url}/#tag=v${pkgver}-${pkgrel}")
sha256sums=('SKIP')

prepare() {
	cd makedeb/
	make prepare PKGVER="${pkgver}" RELEASE="${_release}" TARGET="${_target}"
}

package() {
	cd makedeb/
	make package DESTDIR="${pkgdir}" TARGET="${_target}"
}
