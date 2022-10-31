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
	VERSION="${pkgver}-${pkgrel}" \
		RELEASE="${_release}" \
		TARGET="${_target}" \
		just prepare
}

build() {
	cd makedeb/
	DPKG_ARCHITECTURE="${MAKEDEB_DPKG_ARCHITECTURE}" \
		just build
}

package() {
	cd makedeb/
	DESTDIR="${pkgdir}" \
		just package
}
