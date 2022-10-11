# Maintainer: Hunter Wittenborn <hunter@hunterwittenborn.com>
_release={{ release }}
_target={{ target }}

pkgname={{ pkgname }}
pkgver={{ pkgver }}
pkgrel={{ pkgrel }}
pkgdesc="A simplicity-focused packaging tool for Debian archives"
arch=('all')
license=('GPL3')
depends=(
	'apt'
	'binutils'
	'build-essential'
	'curl'
	'fakeroot'
	'file'
	'gettext'
	'gawk'
	'libarchive-tools'
	'lsb-release'
	'python3'
	'python3-apt'
	'zstd'
)
makedepends=(
	'asciidoctor'
	'git'
	'make'
	'jq'
)
conflicts=('makedeb')
provides=("makedeb=${pkgver}")
url="https://github.com/makedeb/makedeb"

source=("{{ source }}")
sha256sums=('SKIP')

prepare() {
	cd makedeb/
	make prepare PKGVER="${pkgver}" RELEASE="${_release}" TARGET="${_target}" CURRENT_VERSION="${pkgver}-${pkgrel}"
}

package() {
	cd makedeb/
	make package DESTDIR="${pkgdir}" TARGET="${_target}"
}
