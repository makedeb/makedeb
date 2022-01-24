#!/usr/bin/env bash
set -e

# Bases.
targets=('apt' 'mpr' 'aur')
releases=('stable' 'beta' 'alpha')

debian_depends=('apt' 'binutils' 'curl' 'fakeroot'
                'file' 'gettext' 'gawk' 'libarchive-tools'
                'lsb-release' 'python3' 'python3-apt' 'zstd')
debian_makedepends=('asciidoctor' 'git' 'make' 'jq')
debian_conflicts=('makedeb-makepkg' 'makedeb-makepkg-beta' 'makedeb-makepkg-alpha')
debian_provides=("${debian_conflicts[@]}")
debian_replaces=("${debian_conflicts[@]}")

arch_depends=('awk' 'binutils' 'bzip2' 'coreutils'
              'dpkg' 'fakeroot' 'file' 'findutils'
              'gettext' 'gnupg' 'grep' 'gzip'
              'libarchive' 'lsb-release' 'ncurses'
              'sed' 'tar' 'xz')
arch_makedepends=("${debian_makedepends[@]}")
arch_conflicts=("${debian_conflicts[@]}")
arch_provides=("${debian_provides[@]}")
arch_replaces=("${debian_replaces[@]}")

# Variable checks.
for i in 'TARGET' 'RELEASE'; do
	if [[ "${!i+x}" != "x" ]]; then
		echo "${i} isn't set."
		missing_var="x"
	fi
done

if [[ "${missing_var+x}" == "x" ]]; then
	exit 1
fi

for i in "${targets[@]}"; do
	if [[ "${TARGET}" == "$i" ]]; then
		good_target="x"
	fi
done

for i in "${releases[@]}"; do
	if [[ "${RELEASE}" == "$i" ]]; then
		good_release="x"
	fi
done

for i in 'TARGET' 'RELEASE'; do
	var="good_${i,,}"

	if [[ "${!var+x}" != "x" ]]; then
		echo "${i} isn't set to a valid value."
		bad_var="x"
	fi
done

if [[ "${bad_var+x}" == "x" ]]; then
	exit 1
fi

# Get needed info.
config_file="$(cat "$(git rev-parse --show-toplevel)"/.data.json)"
pkgver="$(echo "${config_file}" | jq -r ".current_pkgver")"
pkgrel="$(echo "${config_file}" | jq -r ".current_pkgrel")"

if [[ "${RELEASE}" == "stable" ]]; then
    pkgname="makedeb"
else
    pkgname="makedeb-${RELEASE}"
fi

if [[ "${TARGET}" == "apt" || "${TARGET}" == "mpr" ]]; then
    var_prefix="debian"
else
    TARGET="arch"
    var_prefix="arch"
fi

depends_var="${var_prefix}_depends[@]"
makedepends_var="${var_prefix}_makedepends[@]"
conflicts_var="${var_prefix}_conflicts[@]"
provides_var="${var_prefix}_provides[@]"
replaces_var="${var_prefix}_replaces[@]"

depends=("${!depends_var}")
makedepends=("${!makedepends_var}")
conflicts=("${!conflicts_var}")
provides=("${!provides_var}")
replaces=("${!replaces_var}")

depends="${depends[@]@Q}"
makedepends="${makedepends[@]@Q}"
conflicts="${conflicts[@]@Q}"
provides="${provides[@]@Q}"
replaces="${replaces[@]@Q}"

# Generate the PKGBUILD file.
if [[ "${TARGET}" == "apt" ]]; then
	extra_sed_args=('-e' "s|git+\${url}|git+file://$(git rev-parse --show-toplevel)|")
fi

template="$(cat TEMPLATE.PKGBUILD)"

echo "${template}" | sed -e "s|\$\${pkgname}|${pkgname}|" \
			 -e "s|\$\${pkgver}|${pkgver}|" \
			 -e "s|\$\${pkgrel}|${pkgrel}|" \
			 -e "s|\$\${release}|${RELEASE}|" \
			 -e "s|\$\${target}|${TARGET}|" \
			 -e "s|\$\${depends}|${depends}|" \
			 -e "s|\$\${makedepends}|${makedepends}|" \
			 -e "s|\$\${conflicts}|${conflicts}|" \
			 -e "s|\$\${provides}|${provides}|" \
			 -e "s|\$\${replaces}|${replaces}|" \
			 -e "s|\$\${url}|${url}|" \
			 "${extra_sed_args[@]}"
