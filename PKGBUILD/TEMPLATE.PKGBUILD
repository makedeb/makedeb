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
		BUILD_COMMIT="$(git rev-parse HEAD)" \
		just prepare
}

build() {
	cd makedeb/
	local no_worker_sizes_distros=('bionic')
	export DPKG_ARCHITECTURE="${MAKEDEB_DPKG_ARCHITECTURE}"

	if ! in_array "${MAKEDEB_DISTRO_CODENAME}" "${no_worker_sizes_distros[@]}"; then
		export RUST_APT_WORKER_SIZES=1
	fi

	just build
}

package() {
	cd makedeb/
	DESTDIR="${pkgdir}" \
		just package
}

# vim: set syntax=bash sw=4 expandtab:
