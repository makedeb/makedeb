# Maintainer: Hunter Wittenborn <hunter@hunterwittenborn.com>

{pkgname}
{pkgver}
{pkgrel}
{pkgdesc}
{arch}
{license}
{depends}
{optdepends}
{conflicts}
{url}
# INTENTIONAL BREAK
source=("${url}/archive/refs/tags/v${pkgver}.tar.gz")
sha256sums=('SKIP')
# INTENTIONAL BREAK
package() {
	# Create single file for makedeb
	mkdir -p "${pkgdir}/usr/bin"
	cd "makedeb-${pkgver}"
	# INTENTIONAL BREAK
	# Add bash shebang
	echo '#!/usr/bin/env bash' > "${pkgdir}/usr/bin/makedeb"
	# INTENTIONAL BREAK
	# Copy functions
	for i in $(find "src/functions/"); do
		if ! [[ -d "${i}" ]]; then
			cat "${i}" >> "${pkgdir}/usr/bin/makedeb"
		fi
	done
	cat "src/makedeb.sh" >> "${pkgdir}/usr/bin/makedeb"
	# INTENTIONAL BREAK
	chmod 555 "${pkgdir}/usr/bin/makedeb"
	# INTENTIONAL BREAK
	# Set package version and build type
	sed -i "s|makedeb_package_version=.*|makedeb_package_version=${pkgver}|" "${pkgdir}/usr/bin/makedeb"
	# INTENTIONAL BREAK
	# Remove testing commands
	sed -i 's|.*# REMOVE AT PACKAGING||g' "${pkgdir}/usr/bin/makedeb"
}
