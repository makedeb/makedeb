# Maintainer: Hunter Wittenborn: <hunter@hunterwittenborn.com>

# Used to obtain folder names for local repository
_gitdir=$(git rev-parse --show-toplevel)
_foldername=$(basename "${_gitdir}")

pkgname=makedeb-alpha
pkgver={pkgver}
pkgrel=1
pkgdesc="Create Debian archives from PKGBUILDs (alpha release)"
arch=('any')
license=('GPL3')
depends=('bash' 'binutils' 'tar' 'file' 'makedeb-makepkg-alpha')
optdepends=('apt' 'git')
conflicts=('makedeb' 'makedeb-beta')
provides=('makedeb')
url="https://github.com/makedeb/makedeb"

source=("git+file://${_gitdir}")
sha256sums=('SKIP')

package() {
    # Create single file for makedeb
    mkdir -p "${pkgdir}/usr/bin"
    cd "${srcdir}/${_foldername}"

    # Add bash shebang
    echo '#!/usr/bin/env bash' > "${pkgdir}/usr/bin/makedeb"

    # Copy functions
    for i in $(find "src/functions/"); do
        if ! [[ -d "${i}" ]]; then
            cat "${i}" >> "${pkgdir}/usr/bin/makedeb"
        fi
    done
    cat "src/makedeb.sh" >> "${pkgdir}/usr/bin/makedeb"

    chmod 555 "${pkgdir}/usr/bin/makedeb"

    # Set package version and build type
    sed -i "s|makedeb_package_version=.*|makedeb_package_version=${pkgver}|" "${pkgdir}/usr/bin/makedeb"

    # Remove testing commands
    sed -i 's|.*# REMOVE AT PACKAGING||g' "${pkgdir}/usr/bin/makedeb"
}
