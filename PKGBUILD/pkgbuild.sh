#!/usr/bin/env bash
set -euo pipefail

depends=('git' 'coreutils' 'apt' 'perl' 'libdpkg-perl' 'libapt-pkg-perl' 'bash>4' 'curl' 'fakeroot' 'file' 'gettext' 'gawk' 'libarchive-tools' 'lsb-release' 'zstd')
makedepends=('asciidoctor')

error() {
	echo "ERROR: ${*}"
}

# Make sure needed variables are set.
failed_checks=0

declare TARGET="${TARGET:-apt}"
declare RELEASE="${RELEASE:-stable}"

# Make sure needed software is installed.
for prgm in curl jq cat; do
	if ! type -t "${prgm}" 1> /dev/null; then
		error "Program '${prgm}' isn't installed."
		failed_checks=1
	fi
done

if (( "${failed_checks}" )); then
	exit 1
fi

# Get needed variables.
new_pkgver="$(cat .data.json | jq -r '.current_pkgver')"
releases="$(curl 'https://api.github.com/repos/makedeb/makedeb/releases?per_page=100' | jq -r '.[].name')"

case "${RELEASE}" in
	stable)
		pkgname='makedeb'
		release="$(echo "${releases}" | grep 'v[0-9.-]*$')"
		;;
	beta|alpha)
		pkgname="makedeb-${RELEASE}"
		release="$(echo "${releases}" | grep "v[0-9.]*-${RELEASE}[0-9]*\$")"
		;;
	*)
		error "Invalid release '${RELEASE}'.";
		exit 1
		;;
esac

release="$(echo "${release}" | head -n 1 | sed 's|^v||')"

# Get the pkgver by checking the current latest pkgver for this release, and bumping it as necesary.
current_pkgver="$(echo "${release}" | grep -o '^[^-]*')"
current_pkgrel="$(echo "${release}" | grep -o '[^-]*$')"

if [[ "${new_pkgver}" != "${current_pkgver}" ]]; then
	new_pkgrel="${RELEASE}"
else
	declare -i pkgrel_norelease="$(echo "${current_pkgrel}" | grep -o '[0-9]*$')"
	if [[ "${BUMP_PKGREL:+x}" == 'x' ]]; then
		pkgrel_norelease+=1
	fi

	# We don't want `pkgrel`s such as 'alpha0', we want just 'alpha' in those situations.
	if [[ "${pkgrel_norelease}" == '0' ]]; then
		new_pkgrel="${RELEASE}"
	else
		new_pkgrel="${RELEASE}${pkgrel_norelease}"
	fi
fi
# 's,^\(declare '${1}'[ ]*=\).*,\1'"${2}"',g'
# Print out the generated PKGBUILD.

cat PKGBUILD/TEMPLATE.PKGBUILD | sed \
    -e 's,^\(_release[ ]*=\).*,\1'"${RELEASE}"',g'\
    -e 's,^\(_target[ ]*=\).*,\1'"${TARGET}"',g'\
    -e 's,^\(pkgname[ ]*=\).*,\1'"${pkgname}"',g'\
    -e 's,^\(pkgver[ ]*=\).*,\1'"${new_pkgver}"',g'\
    -e 's,^\(pkgrel[ ]*=\).*,\1'"${new_pkgrel}"',g'| {
		if [[ "${RELEASE}" == 'stable' ]]; then
			grep -Ev '^conflicts=|^provides='
		else
			cat
		fi
	} | {
		if [[ "${LOCAL:+x}" == '' ]]; then
			sed 's|{{ source }}|makedeb::git+${url}/#tag=v${pkgver}-${pkgrel}|g'
		else
			sed 's|{{ source }}|makedeb::git+file://$(git rev-parse --show-toplevel)|'
		fi
	}
#cat PKGBUILD/TEMPLATE.PKGBUILD | sed \
	#-e "s|{{ release }}|${RELEASE}|g" \
	#-e "s|{{ target }}|${TARGET}|g" \
	#-e "s|{{ pkgname }}|${pkgname}|g" \
	#-e "s|{{ pkgver }}|${new_pkgver}|g" \
	#-e "s|{{ pkgrel }}|${new_pkgrel}|g" | {
		#if [[ "${RELEASE}" == 'stable' ]]; then
			#grep -Ev '^conflicts=|^provides='
		#else
			#cat
		#fi
	#} | {
		#if [[ "${LOCAL:+x}" == '' ]]; then
			#sed 's|{{ source }}|makedeb::git+${url}/#tag=v${pkgver}-${pkgrel}|g'
		#else
			#sed 's|{{ source }}|makedeb::git+file://$(git rev-parse --show-toplevel)|'
		#fi
	#}
