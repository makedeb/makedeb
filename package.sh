#!/usr/bin/env bash
set -eo pipefail
install -Dm 644 completions/makedeb.bash "${DESTDIR}/usr/share/bash-completion/completions/${NAME}"
{
	BUILD_COMMIT="$(git rev-parse HEAD 2>/dev/null)"
} || {
	BUILD_COMMIT="default"
}
cd src/
mkdir -p "${DESTDIR}/usr/bin"
main_file="${DESTDIR}/usr/bin/${NAME}"

install -Dm 755 ./main.sh "${main_file}"

define(){
    sed -i 's,^\(declare '${1}'[ ]*=\).*,\1'"${2}"',g' "${main_file}"
}

define makepkg_program_name "${NAME}"
define MAKEDEB_VERSION "${VERSION}"
define MAKEDEB_RELEASE "${RELEASE}"
define MAKEDEB_INSTALLATION_SOURCE "${TARGET}"
define FILESYSTEM_PREFIX '"$(realpath $(dirname $0)/../../)"'
define MAKEDEB_BUILD_COMMIT "${BUILD_COMMIT}"
define LIBRARY '"${LIBRARY:-${FILESYSTEM_PREFIX}/usr/share/'"${NAME}"'}"'
define MAKEPKG_CONF '"${MAKEPKG_CONF:-${FILESYSTEM_PREFIX}/etc/makepkg.conf}"'
define EXTENSIONS_DIR '"${FILESYSTEM_PREFIX}/usr/lib/'"${NAME}"'"'

install -D ./makepkg.conf "${DESTDIR}/etc/makepkg.conf"

cd functions/
find ./ -type f -exec install -Dm 755 '{}' "${DESTDIR}/usr/share/${NAME}/{}" \;
cd ..


cd extensions/
find ./ -type f -exec install -Dm 755 '{}' "${DESTDIR}/usr/lib/${NAME}/{}" \;
cd ..
cd ..

man_dest="${DESTDIR}/man2"
cp man ${man_dest} -RfTn
sed -i "s|\$\${pkgver}|${VERSION}|" ${man_dest}/*

asciidoctor -b manpage ${man_dest}/makedeb.8.adoc -o "${DESTDIR}/usr/share/man/man8/${NAME}.8"
asciidoctor -b manpage ${man_dest}/makedeb-extension.5.adoc -o "${DESTDIR}/usr/share/man/man5/${NAME}-extension.5"
asciidoctor -b manpage ${man_dest}/pkgbuild.5.adoc -o "${DESTDIR}/usr/share/man/man5/pkgbuild.5"

rm -R ${man_dest}
