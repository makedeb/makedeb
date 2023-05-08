#!/usr/bin/env bash
set -eo pipefail
install -Dm 644 completions/makedeb.bash "${DESTDIR}/usr/share/bash-completion/completions/${NAME}"

BUILD_COMMIT="$(git rev-parse HEAD)" 

cd src/
mkdir -p "${DESTDIR}/usr/bin"
main_file="${DESTDIR}/usr/bin/${NAME}"
cat << EOF >> ${main_file}
#!/usr/bin/env bash
#
#   makepkg - make packages compatible for use with apt
#
#   Copyright (c) 2006-2021 Pacman Development Team <pacman-dev@archlinux.org>
#   Copyright (c) 2002-2006 by Judd Vinet <jvinet@zeroflux.org>
#   Copyright (c) 2005 by Aurelien Foret <orelien@chez.com>
#   Copyright (c) 2006 by Miklos Vajna <vmiklos@frugalware.org>
#   Copyright (c) 2005 by Christian Hamar <krics@linuxforum.hu>
#   Copyright (c) 2006 by Alex Smith <alex@alex-smith.me.uk>
#   Copyright (c) 2006 by Andras Voroskoi <voroskoi@frugalware.org>
#   Copyright (c) 2023 by huakim <fijik19@gmail.com>

#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

EOF
const(){
    echo "declare -r ${1}=${2}" >> ${main_file}
}
define(){
    echo "${1}=${2}" >> ${main_file}
}
const makepkg_program_name "${NAME}"
const MAKEDEB_VERSION ${VERSION}
const MAKEDEB_RELEASE ${RELEASE}
const MAKEDEB_INSTALLATION_SOURCE ${TARGET}
const FILESYSTEM_PREFIX '"$(realpath $(dirname $0)/../../)"'
const MAKEDEB_BUILD_COMMIT ${BUILD_COMMIT}
const BUILDSCRIPT 'PKGBUILD'
const startdir '"$(pwd -P)"'
const confdir '"${FILESYSTEM_PREFIX}/etc"'
define MAKEDEB_DPKG_ARCHITECTURE '"${MAKEDEB_DPKG_ARCHITECTURE:-"$(dpkg --print-architecture)"}"'
define MAKEDEB_DISTRO_CODENAME '"${MAKEDEB_DISTRO_CODENAME:-"$(lsb_release -cs)"}"'
define LIBRARY '"${LIBRARY:-"${FILESYSTEM_PREFIX}/usr/share/'"${NAME}"'"}"'
define MAKEPKG_CONF '"${MAKEPKG_CONF:-"${FILESYSTEM_PREFIX}/etc/makepkg.conf"}"'
define EXTENSIONS_DIR '"${FILESYSTEM_PREFIX}/usr/lib/'"${NAME}"'"'


cat < ./main.sh >> ${main_file}

install -D ./makepkg.conf "${DESTDIR}/etc/makepkg.conf"

cd functions/
find ./ -type f -exec install -D '{}' "${DESTDIR}/usr/share/${NAME}/{}" \;
cd ..

cd extensions/
find ./ -type f -exec install -D '{}' "${DESTDIR}/usr/lib/${NAME}/{}" \;
cd ..
cd ..

man_dest="${DESTDIR}/man2"
cp man ${man_dest} -RfTn
sed -i "s|\$\${pkgver}|${VERSION}|" ${man_dest}/*

asciidoctor -b manpage ${man_dest}/makedeb.8.adoc -o "${DESTDIR}/usr/share/man/man8/${NAME}.8"
asciidoctor -b manpage ${man_dest}/makedeb-extension.5.adoc -o "${DESTDIR}/usr/share/man/man5/${NAME}-extension.5"
asciidoctor -b manpage ${man_dest}/pkgbuild.5.adoc -o "${DESTDIR}/usr/share/man/man5/pkgbuild.5"

rm -R ${man_dest}
