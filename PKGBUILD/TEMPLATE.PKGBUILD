# Maintainer: Hunter Wittenborn <hunter@hunterwittenborn.com>
_release=stable
_target=apt

pkgname=makedeb
pkgver=17.1.3
pkgrel=${_release}
pkgdesc="A simplicity-focused packaging tool for Debian archives"
arch=('all')
multiarch=foreign
provides=('build-essential')
depends=(
	'git' 
	'coreutils' 
	'apt'
	'bash>4.2' 
	'curl' 
	'fakeroot' 
	'file' 
	'gettext' 
	'gawk' 
	'libarchive-tools' 
	'lsb-release' 
    'libdpkg-parse-perl'
    'libdpkg-perl'
    'libarray-diff-perl'
	'zstd'
)
makedepends=('asciidoctor')

license=('GPL3')
backup=('/etc/makepkg.conf')
url="https://github.com/makedeb/${pkgname}.git"

source=("git+${url}")
sha256sums=('SKIP')

#pkgver(){
#    dir="${srcdir}/${pkgname}/"
#    if [[ -d "${dir}" ]]; then
#        cd "${dir}"
#    fi
#    {
#	ver=$(git rev-list --count --all 2>/dev/null)
#	echo "${ver}"	
#    } | {
#	echo ${pkgver}
#    }
#}

package() {
    cd "${srcdir}/${pkgname}/"
    VERSION="${pkgver}-${pkgrel}"   \
    RELEASE="${_release}"           \
    NAME="${pkgname}"               \
    TARGET="${_target}"             \
    DESTDIR="${pkgdir}"             \
    . ./scripts/package.sh
}

# vim: set syntax=bash sw=4 expandtab:
