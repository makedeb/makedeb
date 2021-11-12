#!/usr/bin/env bash
set -e

# Bases.
targets=('local' 'mpr' 'aur')
releases=('stable' 'beta' 'alpha')

base_stable_conflicts=('makedeb-beta' 'makedeb-alpha' 'makedeb-makepkg')
base_beta_conflicts=('makedeb' 'makedeb-alpha' 'makedeb-makepkg-beta')
base_alpha_conflicts=('makedeb' 'makedeb-beta' 'makedeb-makepkg-alpha')

base_debian_depends=('apt' 'bash' 'binutils' 'file' 'lsb-release' 'python3' 'python3-apt' 'tar')
base_debian_makedepends=('asciidoctor' 'git' 'make' 'jq')

base_arch_depends=('tar' 'binutils' 'lsb-release' 'dpkg')
base_arch_makedepends=("${base_debian_makedepends[@]}")

# Depends.
local_stable_depends=("${base_debian_depends[@]}")
local_beta_depends=("${base_debian_depends[@]}")
local_alpha_depends=("${base_debian_depends[@]}")

mpr_stable_depends=("${local_stable_depends[@]}")
mpr_beta_depends=("${local_beta_depends[@]}")
mpr_alpha_depends=("${local_alpha_depends[@]}")

aur_stable_depends=("${base_arch_depends[@]}")
aur_beta_depends=("${base_arch_depends[@]}")
aur_alpha_depends=("${base_arch_depends[@]}")

# Makedepends.
local_stable_makedepends=("${base_debian_makedepends[@]}")
local_beta_makedepends=("${base_debian_makedepends[@]}")
local_alpha_makedepends=("${base_debian_makedepends[@]}")

mpr_stable_makedepends=("${base_debian_makedepends[@]}")
mpr_beta_makedepends=("${base_debian_makedepends[@]}")
mpr_alpha_makedepends=("${base_debian_makedepends[@]}")

aur_stable_makedepends=("${base_arch_makedepends[@]}")
aur_beta_makedepends=("${base_arch_makedepends[@]}")
aur_alpha_makedepends=("${base_arch_makedepends[@]}")

# Conflicts
local_stable_conflicts=("${base_stable_conflicts[@]}")
local_beta_conflicts=("${base_beta_conflicts[@]}")
local_alpha_conflicts=("${base_alpha_conflicts[@]}")

mpr_stable_conflicts=("${base_stable_conflicts[@]}")
mpr_beta_conflicts=("${base_beta_conflicts[@]}")     
mpr_alpha_conflicts=("${base_alpha_conflicts[@]}")

aur_stable_conflicts=("${base_stable_conflicts[@]}")
aur_beta_conflicts=("${base_beta_conflicts[@]}")     
aur_alpha_conflicts=("${base_alpha_conflicts[@]}")

##################
## BEGIN SCRIPT ##
##################
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

config_file="$(cat "$(git rev-parse --show-toplevel)"/.data.json)"
pkgver="$(echo "${config_file}" | jq -r ".current_pkgver")"
pkgrel="$(echo "${config_file}" | jq -r ".current_pkgrel")"

# Generate the PKGBUILD file.
if [[ "${RELEASE}" == "stable" ]]; then
	pkgname="makedeb"
else
	pkgname="makedeb-${RELEASE}"
fi

depends="${TARGET}_${RELEASE}_depends[@]"
makedepends="${TARGET}_${RELEASE}_makedepends[@]"
conflicts="${TARGET}_${RELEASE}_conflicts[@]"

depends=("${!depends}")
makedepends=("${!makedepends}")
conflicts=("${!conflicts}")

depends="${depends[@]@Q}"
makedepends="${makedepends[@]@Q}"
conflicts="${conflicts[@]@Q}"

if [[ "${TARGET}" == "local" ]]; then
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
			 -e "s|\$\${url}|${url}|" \
			 "${extra_sed_args[@]}"
