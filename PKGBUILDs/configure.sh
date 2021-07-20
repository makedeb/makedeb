#!/usr/bin/env bash
set -e
cd "$(git rev-parse --show-toplevel)/PKGBUILDs"

# Functions
get_definitions() {
	source PKGBUILDs/definitions.sh

	debian_depends="$(eval echo "\${${1}_debian_depends[@]@Q}")"
	arch_depends="$(eval echo "\${${1}_arch_depends[@]@Q}")"

	debian_conflicts="$(eval echo "\${${1}_debian_conflicts[@]@Q}")"
	arch_conflicts="$(eval echo "\${${1}_arch_conflicts[@]@Q}")"

	debian_optdepends="$(eval echo "\${${1}_debian_optdepends[@]@Q}")"
	arch_optdepends="$(eval echo "\${${1}_arch_optdepends[@]@Q}")"
}

# Argument check
if [[ "${1}" != "stable" && "${1}" != "beta" && "${1}" != "alpha" ]]; then
	echo "Invalid release type '${1}'."
	exit 1
fi

# Get dependencies
get_definitions "${1}"

# Source local PKGBUILD
source src/PKGBUILD

cd PKGBUILDs

# Set up AUR and MPR PKGBUILDs
rm -f MPR.PKGBUILD
rm -f AUR.PKGBUILD

cp TEMPLATE.PKGBUILD MPR.PKGBUILD
cp TEMPLATE.PKGBUILD AUR.PKGBUILD


# Set package name
if [[ "${1}" == "stable" ]]; then
	sed -i 's|^{pkgname}|pkgname=makedeb|' MPR.PKGBUILD
	sed -i 's|^{pkgname}|pkgname=makedeb|' AUR.PKGBUILD

else
	sed -i "s|^{pkgname}|pkgname=makedeb-${1}|" MPR.PKGBUILD
	sed -i "s|^{pkgname}|pkgname=makedeb-${1}|" AUR.PKGBUILD

fi

# Set dependencies
for i in depends conflicts optdepends; do

	string_value="$(eval echo "\${debian_${i}}")"

	if [[ "${string_value}" != "" ]]; then
		sed -i "s|^{$i}|$i=(${string_value})|" MPR.PKGBUILD
	else
		sed -i "s|^{$i}||" MPR.PKGBUILD
	fi

	string_value="$(eval echo "\${arch_${i}}")"

	if [[ "${string_value}" != "" ]]; then
		sed -i "s|^{$i}|$i=(${string_value})|" AUR.PKGBUILD
	else
		sed -i "s|^{$i}||" AUR.PKGBUILD
	fi

done

# Set everything else
for i in pkgver pkgrel; do
	sed -i "s|^{$i}|$i=$(eval echo \${$i})|" MPR.PKGBUILD
	sed -i "s|^{$i}|$i=$(eval echo \${$i})|" AUR.PKGBUILD
done

for i in pkgdesc url; do
	sed -i "s|^{$i}|$i=\"$(eval echo \${$i})\"|" MPR.PKGBUILD
	sed -i "s|^{$i}|$i=\"$(eval echo \${$i})\"|" AUR.PKGBUILD
done

sed -i "s|(git release)|(${1} release)|" MPR.PKGBUILD
sed -i "s|(git release)|(${1} release)|" AUR.PKGBUILD


for i in arch license; do
	sed -i "s|^{$i}|$i=($(eval echo \${$i@Q}))|" MPR.PKGBUILD
	sed -i "s|^{$i}|$i=($(eval echo \${$i@Q}))|" AUR.PKGBUILD
done

for i in 'MPR.PKGBUILD' 'AUR.PKGBUILD'; do
	cat "${i}" | tr -s '\n' | sed 's|# INTENTIONAL BREAK||g' | tee "${i}" &> /dev/null
done

sed -i "s|^}$|\n\t# Set target OS to Arch Linux\n\tsed -i 's\|target_os=\"debian\"\|target_os=\"arch\"\|' \"\${pkgdir}/usr/bin/makedeb\"\n}|" AUR.PKGBUILD

echo "PKGBUILDs have been sucesfully generated."
