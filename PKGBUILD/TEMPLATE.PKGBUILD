# Maintainer: Hunter Wittenborn <hunter@hunterwittenborn.com>
_release={{ release }}
_target={{ target }}

pkgname={{ pkgname }}
pkgver={{ pkgver }}
pkgrel={{ pkgrel }}
pkgdesc="A simplicity-focused packaging tool for Debian archives"
arch=('any')
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
	'zstd'
)
makedepends=(
	'asciidoctor'
	'cargo'
	'git'
	'make'
	'jq'
)
conflicts=('makedeb')
provides=("makedeb=${pkgver}")
license=('GPL3')
backup=('/etc/makepkg.conf')
url="https://github.com/makedeb/makedeb"

source=("{{ source }}")
sha256sums=('SKIP')

prepare() {
	cd makedeb/
	make prepare PKGVER="${pkgver}" RELEASE="${_release}" TARGET="${_target}" CURRENT_VERSION="${pkgver}-${pkgrel}"
}

build() {
	cd makedeb/
	make build
}

package() {
	cd makedeb/
	make package DESTDIR="${pkgdir}" TARGET="${_target}"
}
