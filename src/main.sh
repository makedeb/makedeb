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

declare makepkg_program_name=makedeb
declare MAKEDEB_VERSION='version'
declare MAKEDEB_RELEASE='release'
declare MAKEDEB_INSTALLATION_SOURCE=apt
declare FILESYSTEM_PREFIX="$(realpath $(dirname $0)/)"
declare MAKEDEB_BUILD_COMMIT=default
declare BUILDSCRIPT='PKGBUILD'
declare startdir="$(pwd -P)"
declare MAKEDEB_DPKG_ARCHITECTURE="${MAKEDEB_DPKG_ARCHITECTURE:-$(dpkg --print-architecture)}"
declare MAKEDEB_DISTRO_CODENAME="${MAKEDEB_DISTRO_CODENAME:-$(lsb_release -cs)}"
declare LIBRARY="${LIBRARY:-${FILESYSTEM_PREFIX}/functions}"
declare MAKEPKG_CONF="${MAKEPKG_CONF:-${FILESYSTEM_PREFIX}/makepkg.conf}"
declare EXTENSIONS_DIR="${FILESYSTEM_PREFIX}/extensions"

# gettext initialization
export TEXTDOMAIN='pacman-scripts'
export TEXTDOMAINDIR='/usr/share/locale'


# file -i does not work on Mac OSX unless legacy mode is set
export COMMAND_MODE='legacy'

# Ensure CDPATH doesn't screw with our cd calls
unset CDPATH

# Ensure GREP_OPTIONS doesn't screw with our grep calls
unset GREP_OPTIONS

#declare -r makepkg_program_name="makepkg"
#declare -r confdir="${FILESYSTEM_PREFIX}/etc"
#declare -r BUILDSCRIPT='PKGBUILD'
#declare -r startdir="$(pwd -P)"

#declare -r MAKEDEB_DPKG_ARCHITECTURE="${MAKEDEB_DPKG_ARCHITECTURE:-"$(dpkg --print-architecture)"}"
#declare -r MAKEDEB_DISTRO_CODENAME="${MAKEDEB_DISTRO_CODENAME:-"$(lsb_release -cs)"}"

#LIBRARY="${LIBRARY:-"${FILESYSTEM_PREFIX}/usr/share/makedeb"}"
#MAKEPKG_CONF="${MAKEPKG_CONF:-"${FILESYSTEM_PREFIX}/etc/makepkg.conf"}"
#EXTENSIONS_DIR="${FILESYSTEM_PREFIX}/usr/lib/makedeb"

MAKEDEB_BINARY="${0}"

# A variable declaring if makedeb is being ran from a packaged release or directly from the Git repository.
# This is used to set up makedeb to be able to run from the local files when needed.
#MAKEDEB_PACKAGED=0

#if ! (( MAKEDEB_PACKAGED )); then
#	set -e
#	if [[ "${IN_MAKEDEB_RS:+x}" == "" ]]; then
		# Cargo appears to be leaking memory when using the libgit2 library, so use the Git CLI for registry updates.
#		cargo build
#		export IN_MAKEDEB_RS=1
#	fi

#	cd "$(dirname "${MAKEDEB_BINARY}")"
#	LIBRARY="$(git rev-parse --show-toplevel)/src/functions"
#	MAKEPKG_CONF="$(git rev-parse --show-toplevel)/src/makepkg.conf"
#	EXTENSIONS_DIR="$(git rev-parse --show-toplevel)/src/extensions"
#	MAKEDEB_BINARY="$(git rev-parse --show-toplevel)/src/main.sh"
#	set +e
#fi

# Options
APTARGS=()
INSTALLED=()
ASDEPS=0
ALLOW_DOWNGRADES=0
BUILDFUNC=0
BUILDPKG=1
CHECKFUNC=0
CLEANBUILD=0
CLEANUP=0
DESTROYSYSTEM=0
FORCE=0
GENINTEG=0
HOLDVER=0
IGNOREARCH=0
INFAKEROOT=0
INSTALL=0
LOGGING=0
LINTPKGBUILD=0
MPR_CHECK=0
MAKEDEB_MESSAGES=()
MAKEDEB_MESSAGE_TYPES=()
NEEDED=0
RECOMMENDS_PACKAGES='D'
SUGGESTS_PACKAGES='D'
NOARCHIVE=0
NOBUILD=0
NOCHECK=0
NOCONFIRM=0
NODEPS=0
NOEXTRACT=0
PKGFUNC=0
PKGVERFUNC=0
PREPAREFUNC=0
PRINTCONTROL=0
PRINTSRCINFO=0
REPKG=0
REPRODUCIBLE=0
RMDEPS=0
SKIPCHECKSUMS=0
SKIPPGPCHECK=0
SIGNPKG=''
SPLITPKG=0
SOURCEONLY=0
SUDOARGS=()
SYNCDEPS=0
VERIFYSOURCE=0
CONTROL_FIELDS=()
REINSTALL=0
DANGER=0

# A default list of extensions to load, these extensions are included with makedeb. This is a publically-exposed variable for PKGBUILDs that can be overwritten.
extensions=(
	'strip'
	'zipman'
    'fields'
)

if [[ -n $SOURCE_DATE_EPOCH ]]; then
	REPRODUCIBLE=1
else
	SOURCE_DATE_EPOCH=$(date +%s)
fi
export SOURCE_DATE_EPOCH

PACMAN_OPTS=()

shopt -s extglob

#################
## SUBROUTINES ##
#################

# Import libmakepkg
for lib in "$LIBRARY"/*.sh; do
	source "$lib"
done

# Special exit call for traps, Don't print any error messages when inside,
# the fakeroot call, the error message will be printed by the main call.
trap_exit() {
	local signal=$1; shift

	if (( ! INFAKEROOT )); then

		# Don't print interrupt errors when formatting output for makedeb.
		if [[ "$signal" == "INT" ]]; then
			echo
			error "$@"
		fi
	fi
	[[ -n $srclinks ]] && rm -rf "$srclinks"

	# unset the trap for this signal, and then call the default handler
	trap -- "$signal"
	kill "-$signal" "$$"
}


# Clean up function. Called automatically when the script exits.
clean_up() {
	local EXIT_CODE=$?

	if (( INFAKEROOT )); then
		# Don't clean up when leaving fakeroot, we're not done yet.
		return 0
	fi

	if [[ -p $logpipe ]]; then
		rm "$logpipe"
	fi

	if (( (EXIT_CODE == E_OK || EXIT_CODE == E_INSTALL_FAILED) && BUILDPKG && CLEANUP )); then
		local pkg file

		# If it's a clean exit and -c/--clean has been passed...
		msg "$(gettext "Cleaning up...")"
		rm -rf "$pkgdirbase" "$srcdir"
		if [[ -n $pkgbase ]]; then
			local fullver=$(get_full_version)
			# Can't do this unless the BUILDSCRIPT has been sourced.
			if (( PKGVERFUNC )); then
				rm -f "${pkgbase}-${fullver}-${CARCH}-pkgver.log"*
			fi
			if (( PREPAREFUNC )); then
				rm -f "${pkgbase}-${fullver}-${CARCH}-prepare.log"*
			fi
			if (( BUILDFUNC )); then
				rm -f "${pkgbase}-${fullver}-${CARCH}-build.log"*
			fi
			if (( CHECKFUNC )); then
				rm -f "${pkgbase}-${fullver}-${CARCH}-check.log"*
			fi
			if (( PKGFUNC )); then
				rm -f "${pkgbase}-${fullver}-${CARCH}-package.log"*
			elif (( SPLITPKG )); then
				for pkg in ${pkgname[@]}; do
					rm -f "${pkgbase}-${fullver}-${CARCH}-package_${pkg}.log"*
				done
			fi

			# clean up dangling symlinks to packages
			for pkg in ${pkgname[@]}; do
				for file in ${pkg}-*-*-*{${PKGEXT},${SRCEXT}}; do
					if [[ -h $file && ! -e $file ]]; then
						rm -f "$file"
					fi
				done
			done
		fi
	fi
}

enter_fakeroot() {
	msg "$(gettext "Entering %s environment...")" "fakeroot"
	fakeroot -- bash -$- "${BASH_SOURCE[0]}" --in-fakeroot "${ARGLIST[@]}" || exit $?
}
 
#makedeb_rs="${LIBRARY}/makedeb_rs"

# Automatically update pkgver variable if a pkgver() function is provided
# Re-sources the PKGBUILD afterwards to allow for other variables that use $pkgver
update_pkgver() {
	msg "$(gettext "Starting %s()...")" "pkgver"
	newpkgver=$(run_function_safe pkgver)
	if (( $? != 0 )); then
		error_function pkgver
	fi
	if ! check_pkgver "$newpkgver"; then
		error "$(gettext "pkgver() generated an invalid version: %s")" "$newpkgver"
		exit $E_PKGBUILD_ERROR
	fi

	if [[ -n $newpkgver && $newpkgver != "$pkgver" ]]; then
		if [[ -w $BUILDFILE ]]; then
			mapfile -t buildfile < "$BUILDFILE"
            arrIN=(${newpkgver//-/ })
            ver="${arrIN[0]}"
            rel="${arrIN[1]}"
            if [ -z "${ver}" ]; then
                ver="${pkgver}"
            fi            
            if [ -z "${rel}" ]; then
                rel="${pkgrel}"
            fi
            buildfile=("${buildfile[@]/#pkgver=*([^ ])/pkgver=${ver}}")
			buildfile=("${buildfile[@]/#pkgrel=*([^ ])/pkgrel=${rel}}")
			
            
            if ! printf '%s\n' "${buildfile[@]}" > "$BUILDFILE"; then
				error "$(gettext "Failed to update %s from %s to %s")" \
						"pkgver" "$pkgver" "$newpkgver"
				exit $E_PKGBUILD_ERROR
			fi
			source_safe "$BUILDFILE"
			local fullver=$(get_full_version)
			msg "$(gettext "Updated version: %s")" "$pkgbase $fullver"
		else
			warning "$(gettext "%s is not writeable -- pkgver will not be updated")" \
					"$BUILDFILE"
		fi
	fi
}

# Print 'source not found' error message and exit makepkg
missing_source_file() {
	error "$(gettext "Unable to find source file %s.")" "$(get_filename "$1")"
	plainerr "$(gettext "Aborting...")"
	exit $E_MISSING_FILE
}

error_function() {
	# first exit all subshells, then print the error
	if (( ! BASH_SUBSHELL )); then
		error "$(gettext "A failure occurred in %s().")" "$1"
		plainerr "$(gettext "Aborting...")"
	fi
	exit $E_USER_FUNCTION_FAILED
}

merge_arch_attrs() {
	local attr current_env_vars supported_attrs=(
		provides conflicts depends replaces optdepends
		makedepends checkdepends)

	for attr in "${supported_attrs[@]}"; do
		local distro_attr_data="$(eval echo "\${${distro_release_name}_${attr}_$CARCH[@]}")"

		if [[ "${distro_attr_data}" != "" ]]; then
			local attr_data="${distro_attr_data}"
		else
			local attr_data="$(eval echo "\${${attr}_$CARCH[@]}")"
		fi

		eval "$attr+=(${attr_data})"
	done

	# ensure that calling this function is idempotent.
	unset -v "${supported_attrs[@]/%/_$CARCH}"
}

source_buildfile() {
	source_safe "$@"
}

run_function_safe() {
	local restoretrap restoreshopt

	# we don't set any special shopts of our own, but we don't want the user to
	# muck with our environment.
	restoreshopt=$(shopt -p)

	# localize 'set' shell options to this function - this does not work for shopt
	local -
	shopt -o -s errexit errtrace

	restoretrap=$(trap -p ERR)
	trap "error_function '$1'" ERR

	run_function "$1"

	trap - ERR
	eval "$restoretrap"
	eval "$restoreshopt"
}

run_function() {
	if [[ -z $1 ]]; then
		return 1
	fi
	local pkgfunc="$1"

	if (( ! BASH_SUBSHELL )); then
		msg "$(gettext "Starting %s()...")" "$pkgfunc"
	fi

	cd_safe "$srcdir"
	MSG_PREFIX=" ${pkgfunc}()" "$pkgfunc"
}

run_prepare() {
	run_function_safe "prepare"
}

run_build() {
	if (( "${NOBUILD}" )); then
		warning 'Skipping execution of build() function.'
	else
		run_function_safe "build"
	fi
}

run_check() {
	if (( "${NOCHECK}" )); then
		warning 'Skipping execution of check() function.'
	else
		run_function_safe "check"
	fi
}

run_package() {
	run_function_safe "package${1:+_$1}"
}

write_control_pair() {
    local target_var="${1}"
    local values=()

    for value in "${@:2}"; do
        values+=("${value},")
    done

    if [[ "${#values[@]}" == 0 ]] || [[ "${#values[@]}" == 1 && "${values}" == "," ]]; then
        return
    fi

    echo "${target_var}: ${values[@]}" | sed 's|,$||'
}

write_kv_pair() {
	local key="$1"
	shift

	for val in "$@"; do
		if [[ $val = *$'\n'* ]]; then
			error "$(gettext "Invalid value for %s: %s")" "$key" "$val"
			exit $E_PKGBUILD_ERROR
		fi
		printf "%s = %s\n" "$key" "$val"
	done
}

write_pkginfo() {
	local size=$(dirsize)

	merge_arch_attrs

	check_distro_variables

	printf "# Generated by ${makepkg_program_name} %s\n" "$makepkg_version"
	printf "# using %s\n" "$(fakeroot -v)"

	write_kv_pair "generated-by" "${makepkg_program_name}"
	write_kv_pair "pkgname" "$pkgname"
	write_kv_pair "pkgbase" "$pkgbase"

	local fullver=$(get_full_version)
	write_kv_pair "pkgver" "$fullver"

	# TODO: all fields should have this treatment
	local spd="${pkgdesc//+([[:space:]])/ }"
	spd=("${spd[@]#[[:space:]]}")
	spd=("${spd[@]%[[:space:]]}")

	write_kv_pair "pkgdesc" "$spd"
	write_kv_pair "url" "$url"
	write_kv_pair "builddate" "$SOURCE_DATE_EPOCH"
	write_kv_pair "packager" "$PACKAGER"
	write_kv_pair "size" "$size"
	write_kv_pair "arch" "$pkgarch"

	write_kv_pair "license"     "${license[@]}"
	write_kv_pair "replaces"    "${replaces[@]}"
	write_kv_pair "group"       "${groups[@]}"
	write_kv_pair "conflict"    "${conflicts[@]}"
	write_kv_pair "provides"    "${provides[@]}"
	write_kv_pair "backup"      "${backup[@]}"
	write_kv_pair "depend"      "${depends[@]}"
	write_kv_pair "optdepend"   "${optdepends[@]//+([[:space:]])/ }"
	write_kv_pair "makedepend"  "${makedepends[@]}"
	write_kv_pair "checkdepend" "${checkdepends[@]}"
}

write_buildinfo() {
	write_kv_pair "format" "2"

	write_kv_pair "pkgname" "$pkgname"
	write_kv_pair "pkgbase" "$pkgbase"

	local fullver=$(get_full_version)
	write_kv_pair "pkgver" "$fullver"

	write_kv_pair "pkgarch" "$pkgarch"

	local sum="$(sha256sum "${BUILDFILE}")"
	sum=${sum%% *}
	write_kv_pair "pkgbuild_sha256sum" $sum

	write_kv_pair "packager" "${PACKAGER}"
	write_kv_pair "builddate" "${SOURCE_DATE_EPOCH}"
	write_kv_pair "builddir"  "${BUILDDIR}"
	write_kv_pair "startdir"  "${startdir}"
	write_kv_pair "buildtool" "${BUILDTOOL:-${makepkg_program_name}}"
	write_kv_pair "buildtoolver" "${BUILDTOOLVER:-$makepkg_version}"
	write_kv_pair "buildenv" "${BUILDENV[@]}"
	write_kv_pair "options" "${OPTIONS[@]}"
}

write_extra_control_fields() {
	local control_field
	local control_key
	local control_value

	for control_field in "${MERGED_CONTROL_FIELDS[@]}"; do
		echo "${control_field}"
	done
}

write_control_info() {
	local fullver=$(get_full_version)

	write_control_pair "Package" "${pkgname}"
	write_control_pair "Version" "${fullver}"
	write_control_pair "Description" "${pkgdesc}"
	write_control_pair "Architecture" "${pkgarch}"
	write_control_pair "License" "${license[@]}"
	write_control_pair "Maintainer" "${maintainer[@]}"
	write_control_pair "Homepage" "${url}"
	write_control_pair "Pre-Depends" "${predepends[@]}"
	write_control_pair "Depends" "${depends[@]}"
	write_control_pair "Recommends" "${recommends[@]}"
	write_control_pair "Suggests" "${suggests[@]}"
	write_control_pair "Conflicts" "${conflicts[@]}"
	write_control_pair "Provides" "${provides[@]}"
	write_control_pair "Replaces" "${replaces[@]}"
	write_control_pair "Breaks" "${breaks[@]}"
	write_extra_control_fields
}

create_deb() {
	echo '2.0' > ./debian-binary
	cd DEBIAN/
	mapfile -t control_files < <(find ./ -mindepth 1 -maxdepth 1)
	tar -czf ./control.tar.gz "${control_files[@]}"
	mv control.tar.gz ../
	cd ../

	mapfile -t package_files < <(find ./ -mindepth 1 -maxdepth 1 -not -path "./DEBIAN" -not -path './debian-binary' -not -path './control.tar.gz')

	# Tar doesn't like no files being provided for an archive.
	if [[ "${#package_files[@]}" == 0 ]]; then
		tar -czf ./data.tar.gz --files-from /dev/null
	else
		tar -czf ./data.tar.gz "${package_files[@]}"
	fi

	ar -rU "${1}" debian-binary control.tar.gz data.tar.gz 2> /dev/null
	rm debian-binary control.tar.gz data.tar.gz
}

create_package() {
	if [[ ! -d $pkgdir ]]; then
		error "$(gettext "Missing %s directory.")" "\$pkgdir/"
		plainerr "$(gettext "Aborting...")"
		exit $E_MISSING_PKGDIR
	fi

	cd_safe "$pkgdir"
	(( NOARCHIVE )) || msg "$(gettext "Creating package \"%s\"...")" "$pkgname"

	# Run any requested extensions.
	# post_package extensions are to be run from '${pkgdir}'.
	local extension

	if [[ "${#post_package_extensions[@]}" -gt 0 ]]; then
		msg2 "$(gettext "Running post-packaging hooks...")"

		for extension in "${post_package_extensions[@]}"; do
			MAKEDEB_POST_PACKAGE=true "${extension}"
		done
	fi

	# Generate package metadata.
	msg2 "$(gettext "Setting up package metadata...")"
	mkdir "${pkgdir}/DEBIAN/"

	msg2 "$(gettext "Generating %s file...")" "control"
	write_control_info > "${pkgdir}/DEBIAN/control"

	if in_array backup "${env_keys[@]}"; then
		printf '%s\n' "${backup[@]}" > "${pkgdir}/DEBIAN/conffiles"
	fi

	# Maintainer scripts.
	for file in preinst postinst prerm postrm; do
		if [[ -z "${!file}" ]]; then
			continue
		fi

		msg2 "$(gettext "Adding %s file to package...")" "${file}"

		if ! cp "${startdir}/${!file}" "${pkgdir}/DEBIAN/${file}"; then
			error "$(gettext "Failed to add %s file to package.")" "$orig"
			exit $E_MISSING_FILE
		fi

		chmod 755 "${pkgdir}/DEBIAN/${file}"
	done

	(( NOARCHIVE )) && return 0

	# Create the archive.
	# If an argument is passed to this function, create the deb at that location.
	local fullver=$(NOEPOCH=1 get_full_version)
	if [[ "${1:+x}" == "x" ]]; then
		local pkg_file="${1}"
	else
		local pkg_file="${PKGDEST}/${pkgname}_${fullver}_${pkgarch}.deb"
	fi

	local ret=0

	if [[ -f $pkg_file ]]; then
		warning2 "$(gettext "Built package %s exists. Removing...")" "$(basename "${pkg_file}")"
		rm "${pkg_file}"
	fi

	cd "${pkgdir}"

	# ensure all elements of the package have the same mtime.
	find . -exec touch -h -d @$SOURCE_DATE_EPOCH {} +

	msg2 "$(gettext "Compressing package...")"
	create_deb "${pkg_file}"
}

create_debug_package() {
	# check if a debug package was requested
	if ! check_option "debug" "y" || ! check_option "strip" "y"; then
		return 0
	fi

	local pkgdir="$pkgdirbase/$pkgbase-debug"

	# check if we have any debug symbols to package
	if dir_is_empty "$pkgdir/usr/lib/debug"; then
		return 0
	fi

	unset groups depends optdepends provides conflicts replaces backup install changelog

	local pkg
	for pkg in ${pkgname[@]}; do
		if [[ $pkg != $pkgbase ]]; then
			provides+=("$pkg-debug")
		fi
	done

	pkgdesc="Detached debugging symbols for $pkgname"
	pkgname=$pkgbase-debug

	create_package
}

create_srcpackage() {
	local ret=0
	msg "$(gettext "Creating source package...")"
	local srclinks="$(mktemp -d "$startdir"/srclinks.XXXXXXXXX)"
	mkdir "${srclinks}"/${pkgbase}

	msg2 "$(gettext "Adding %s...")" "$BUILDSCRIPT"
	ln -s "${BUILDFILE}" "${srclinks}/${pkgbase}/${BUILDSCRIPT}"

	msg2 "$(gettext "Generating %s file...")" .SRCINFO
	write_srcinfo > "$srclinks/$pkgbase"/.SRCINFO

	local file all_sources

	get_all_sources 'all_sources'
	for file in "${all_sources[@]}"; do
		if [[ "$file" = "$(get_filename "$file")" ]] || (( SOURCEONLY == 2 )); then
			local absfile
			absfile=$(get_filepath "$file") || missing_source_file "$file"
			msg2 "$(gettext "Adding %s...")" "${absfile##*/}"
			ln -s "$absfile" "$srclinks/$pkgbase"
		fi
	done

	# set pkgname the same way we do for running package(), this way we get
	# the right value in extract_function_variable
	local pkgname_backup=(${pkgname[@]})
	local i pkgname
	for i in 'changelog' 'install'; do
		local file files

		[[ ${!i} ]] && files+=("${!i}")
		for pkgname in "${pkgname_backup[@]}"; do
			if extract_function_variable "package_$pkgname" "$i" 0 file; then
				files+=("$file")
			fi
		done

		for file in "${files[@]}"; do
			if [[ $file && ! -f "${srclinks}/${pkgbase}/$file" ]]; then
				msg2 "$(gettext "Adding %s file (%s)...")" "$i" "${file}"
				ln -s "${startdir}/$file" "${srclinks}/${pkgbase}/"
			fi
		done
	done
	pkgname=(${pkgname_backup[@]})

	local fullver=$(get_full_version)
	local pkg_file="$SRCPKGDEST/${pkgbase}-${fullver}${SRCEXT}"

	# tar it up
	msg2 "$(gettext "Compressing source package...")"
	cd_safe "${srclinks}"

	# TODO: Maybe this can be set globally for robustness
	shopt -s -o pipefail
	LANG=C bsdtar --no-fflags -cLf - ${pkgbase} | compress_as "$SRCEXT" > "${pkg_file}" || ret=$?

	shopt -u -o pipefail

	if (( ret )); then
		error "$(gettext "Failed to create source package file.")"
		exit $E_PACKAGE_FAILED
	fi

	cd_safe "${startdir}"
	rm -rf "${srclinks}"
}

install_package() {
	(( ! INSTALL )) && return 0
    (( REINSTALL )) && APTARGS+=('--reinstall')

	if (( ! SPLITPKG )); then
		msg "$(gettext "Installing package %s...")" "$pkgname"
	else
		msg "$(gettext "Installing %s package group...")" "$pkgbase"
	fi

	local fullver pkgarch pkg pkglist

	for pkg in ${pkgname[@]}; do
		fullver=$(NOEPOCH=1 get_full_version)
		pkgarch=$(get_pkg_arch $pkg)
		pkglist+=("${PKGDEST}/${pkg}_${fullver}_${pkgarch}.deb")
	done

	if ! sudo apt-get install "${APTARGS[@]}" "${pkglist[@]}"; then
		warning "$(gettext "Failed to install built package(s).")"
		return $E_INSTALL_FAILED
	fi

	if (( "${ASDEPS}" )); then
		msg "$(gettext "Marking built package(s) as automatically installed...")" "${pkgbase}"

		if ! sudo "${SUDOARGS[@]}" -- apt-mark auto "${pkgname[@]}"; then
			warning "$(gettext "Failed to mark built package(s) as automatically installed.")"
		fi
	fi
}

check_build_status() {
	local fullver pkgarch allpkgbuilt somepkgbuilt
	if (( ! SPLITPKG )); then
		fullver=$(get_full_version)
		pkgarch=$(get_pkg_arch)
		if [[ -f $PKGDEST/${pkgname}-${fullver}-${pkgarch}${PKGEXT} ]] \
				 && ! (( FORCE || SOURCEONLY || NOARCHIVE)); then
			if (( INSTALL )); then
				warning "$(gettext "A package has already been built, installing existing package...")"
				install_package
				exit $?
			else
				error "$(gettext "A package has already been built. (use %s to overwrite)")" "-f"
				exit $E_ALREADY_BUILT
			fi
		fi
	else
		allpkgbuilt=1
		somepkgbuilt=0
		for pkg in ${pkgname[@]}; do
			fullver=$(get_full_version)
			pkgarch=$(get_pkg_arch $pkg)
			if [[ -f $PKGDEST/${pkg}-${fullver}-${pkgarch}${PKGEXT} ]]; then
				somepkgbuilt=1
			else
				allpkgbuilt=0
			fi
		done
		if ! (( FORCE || SOURCEONLY || NOARCHIVE)); then
			if (( allpkgbuilt )); then
				if (( INSTALL )); then
					warning "$(gettext "The package group has already been built, installing existing packages...")"
					install_package
					exit $?
				else
					error "$(gettext "The package group has already been built. (use %s to overwrite)")" "-f"
					exit $E_ALREADY_BUILT
				fi
			fi
			if (( somepkgbuilt && ! PKGVERFUNC )); then
				error "$(gettext "Part of the package group has already been built. (use %s to overwrite)")" "-f"
				exit $E_ALREADY_BUILT
			fi
		fi
	fi
}

backup_package_variables() {
	local var
	for var in ${pkgbuild_schema_package_overrides[@]}; do
		local indirect="${var}_backup"
		eval "${indirect}=(\"\${$var[@]}\")"
	done
}

restore_package_variables() {
	local var
	for var in ${pkgbuild_schema_package_overrides[@]}; do
		local indirect="${var}_backup"
		if [[ -n ${!indirect} ]]; then
			eval "${var}=(\"\${$indirect[@]}\")"
		else
			unset ${var}
		fi
	done
}

run_single_packaging() {
	backup_package_variables
	
	# Run the 'package()/package_{pkgname}()' function for this pkgname.
	local pkgdir="$pkgdirbase/$pkgname"
	mkdir "$pkgdir"
	if [[ -n $1 ]] || (( PKGFUNC )); then
		run_package $1
	fi

	# If the package didn't overwrite dependency arrays, we need to format
	# the dependencies back to makedeb-styled ones, as they've already been formatted
	# for control files before now.
	if [[ "${depends[*]}" == "${depends_backup[*]}" ]]; then
		mapfile -t depends < <(
			debian_to_makedeb_deps '' "${depends[@]}"
			debian_to_makedeb_deps 'p!' "${predepends[@]}"
		)
	fi
	predepends=()

	if [[ "${#optdepends[@]}" -eq 0 ]]; then
		mapfile -t optdepends < <(
			debian_to_makedeb_deps 'r!' "${recommends[@]}"
			debian_to_makedeb_deps 's!' "${suggests[@]}"
		)
	fi
	recommends=()
	suggests=()

	if [[ "${conflicts[*]}" == "${conflicts_backup[*]}" ]]; then
		mapfile -t conflicts < <(debian_to_makedeb_deps '' "${conflicts[@]}")
	fi

	if [[ "${provides[*]}" == "${provides_backup[*]}" ]]; then
		mapfile -t provides < <(debian_to_makedeb_deps '' "${provides[@]}")
	fi
	
	if [[ "${replaces[*]}" == "${replaces_backup[*]}" ]]; then
		mapfile -t replaces < <(debian_to_makedeb_deps '' "${replaces[@]}")
	fi

	# Lint, convert deps, and make the package.
	lint_package || exit $E_PACKAGE_FAILED

	convert_dependencies

	remove_optdepends_description recommends "${recommends[@]}"
	remove_optdepends_description suggests "${suggests[@]}"

	convert_relationships predepends "${predepends[@]}"
	convert_relationships depends "${depends[@]}"
	convert_relationships makedepends "${makedepends[@]}"
	convert_relationships checkdepends "${checkdepends[@]}"
	convert_relationships recommends "${recommends[@]}"
	convert_relationships suggests "${suggests[@]}"
	convert_relationships conflicts "${conflicts[@]}"
	convert_relationships provides "${provides[@]}"
	convert_relationships replaces "${replaces[@]}"
	convert_relationships breaks "${breaks[@]}"

	create_package

	restore_package_variables
}

run_split_packaging() {
	for pkgname in ${pkgname[@]}; do
		run_single_packaging $pkgname
	done
}

check_distro_variables() {
	for i in depends optdepends conflicts provides replaces makedepends optdepends; do

		local variable_data="$(eval echo "\${${distro_release_name}_${i}[@]@Q}")"

		if [[ "${variable_data}" != "" ]]; then
			# For some reason the following command fails:
			#   eval declare "${i}"=(${variable_data})
			#
			# *soooo*, we just put it into one string (Presumably bash itself is
			# having an issue processing the above command).
			local declare_string="${i}=(${variable_data})"
			eval export "${declare_string}"
		fi

	done
}

usage() {
	printf "(%s) (%s)\n" "${makepkg_program_name}" "${MAKEDEB_VERSION}"
	echo
	printf -- "$(gettext "(%s) takes PKGBUILD files and creates archives installable via APT")\n" "${makepkg_program_name}"
	echo
	printf -- "$(gettext "Usage: %s [options]")\n" "${makepkg_program_name}"
	echo
    
	printf -- "$(gettext "Common options:")\n"
	printf -- "$(gettext "  -A, --ignorearch      Ignore errors about mismatching architectures")\n"
	printf -- "$(gettext "  -c, --clean           Clean up work files after build")\n"
	printf -- "$(gettext "  -C, --cleanbuild      Remove %s dir before building the package")\n" "\$srcdir/"
	printf -- "$(gettext "  --danger              Run makedeb in dangerous mode")\n"
	printf -- "$(gettext "  -d, --nodeps          Skip all dependency checks")\n"
	printf -- "$(gettext "  -e, --noextract       Do not extract source files (use existing %s dir)")\n" "\$srcdir/"
	printf -- "$(gettext "  -f, --force           Overwrite existing package")\n"
	printf -- "$(gettext "  -g, --geninteg        Generate hashes for source files")\n"
	printf -- "$(gettext "  -h, --help            Show this help menu and exit")\n"
	printf -- "$(gettext "  -H, --field <field>   Append the packaged control file with custom control fields")\n"
	printf -- "$(gettext "  -i, --install         Automatically install the built package(s) after building")\n"
	printf -- "$(gettext "  -V, --version         Show version information and exit")\n"
	printf -- "$(gettext "  -r, --rmdeps          Run 'apt-get autoremove' after a succesfull build")\n"
	printf -- "$(gettext "  -R, --repackage       Repackage contents of the package without rebuilding")\n"
	printf -- "$(gettext "  -s, --syncdeps        Install missing dependencies")\n"
	printf -- "$(gettext "  -V, --version         Show version information and exit")\n"
    printf -- "$(gettext "  --config <file>       Use an alternate config file (instead of '%s')")\n" "${MAKEPKG_CONF}"
	printf -- "$(gettext "  --lint                Link the (%s) for conformity requirements")\n" "$BUILDSCRIPT"
    printf -- "$(gettext "  -m --nocolor          Disable colored output")\n"
	printf -- "$(gettext "  -o --nobuild          Skip running of the 'build()' function in the '%s'")\n" "$BUILDSCRIPT"
	printf -- "$(gettext "  -p --file <file>      Use an alternate build script (instead of '%s')")\n" "$BUILDSCRIPT"
	printf -- "$(gettext "  --nocheck             Skip running of the 'check()' function in the '%s'")\n" "$BUILDSCRIPT"
	printf -- "$(gettext "  --noarchive           Do not create package archive")\n"
	printf -- "$(gettext "  --noprepare           Do not run the %s function in the %s")\n" "prepare()" "$BUILDSCRIPT"
	printf -- "$(gettext "  --nosign              Do not create a signature for the package")\n"
    printf -- "$(gettext "  --printcontrol        Print a generated control file and exit")\n"
	printf -- "$(gettext "  --printsrcinfo        Print a generated .SRCINFO file and exit")\n"
	printf -- "$(gettext "  --sign                Sign the resulting package with %s")\n" "gpg"
    printf -- "$(gettext "  --skipchecksums       Do not verify checksums of the source files")\n"
	printf -- "$(gettext "  --skipinteg           Do not perform any verification checks on source files")\n"
	printf -- "$(gettext "  --skippgpcheck        Do not verify source files with PGP signatures")\n"
	printf -- "$(gettext "  --verifysource        Download source files (if needed) and perform integrity checks")\n"
    echo
	printf -- "$(gettext "The following options can modify the behavior of APT during package and dependency installation:")\n"
	printf -- "$(gettext "  --asdeps              Mark built packages as automatically installed")\n"
	printf -- "$(gettext "  --allowdowngrades     Allow packages to be downgraded")\n"
	printf -- "$(gettext "  --noinstallrecommends Do not look at recommends packages")\n"
	printf -- "$(gettext "  --noinstallsuggests   Do not look at suggests packages")\n"
	printf -- "$(gettext "  --installrecommends   Look at recommends packages")\n"
	printf -- "$(gettext "  --installsuggests     Look at suggests packages")\n"
	printf -- "$(gettext "  --noconfirm           Don't ask before installing packages")\n"
	printf -- "$(gettext "  --reinstall           Automatically reinstall the built package(s) after building")\n"
    printf -- "$(gettext "  --passenv             sudo option (pass environment)")\n"
    
    echo
	printf -- "$(gettext "The following options can modify the behavior of 'sudo' when it is called:")\n"
	#printf -- "$(gettext "  --passenv             Pass the current user's environment variables")\n"
	echo
	printf -- "$(gettext "The following can be used to print (%s)-styled messages:")\n" "${makepkg_program_name}"
	printf -- "$(gettext "  --msg                 Print a msg message to stdout")\n"
	printf -- "$(gettext "  --msg2                Print a msg2 message to stdout")\n"
	printf -- "$(gettext "  --warning             Print a warning message to stderr")\n"
	printf -- "$(gettext "  --warning2            Print a warning2 message to stderr")\n"
	printf -- "$(gettext "  --error               Print an error message to stderr")\n"
	printf -- "$(gettext "  --error2              Print an error2 message to stderr")\n"
	echo
	printf -- "$(gettext "See (%s)(8) for information on all available options and links for obtaining support.")\n" "${makepkg_program_name}"
}

version() {
	printf "${makepkg_program_name} ${MAKEDEB_VERSION}\n" "${makepkg_program_name}"
	printf "${MAKEDEB_RELEASE^} $(gettext "Release")\n"
	printf "$(gettext "Installed from") ${MAKEDEB_INSTALLATION_SOURCE^^}\n"
	printf "$(gettext "Built from") ${MAKEDEB_BUILD_COMMIT}\n"
}

mpr_check() {
	printf "
 .--.                  Pacman v6.0.0 - libalpm v13.0.0
/ _.-' .-.  .-.  .-.   Copyright (C) 2006-2021 Pacman Development Team
\  '-. '-'  '-'  '-'   Copyright (C) 2002-2006 Judd Vinet
 '--'
                       This program may be freely redistributed under
                       the terms of the GNU General Public License.

"
}

###################
## PROGRAM START ##
###################

# ensure we have a sane umask set
umask 0022

# determine whether we have gettext; make it a no-op if we do not
if ! type -p gettext >/dev/null; then
	gettext() {
		printf "%s\n" "$@"
	}
fi

ARGLIST=("$@")

# Parse Command Line Options.
OPT_SHORT='AcCdefghH:iVrRsVmop:'
OPT_LONG=(
"ignorearch" "ignore-arch"
"clean"
"cleanbuild" "clean-build"
"nodeps" "no-deps"
"noextract" "no-extras"
"force" 
"geninteg" "gen-integ"
"help"
"field:"
"install"
"version" "danger"
"rmdeps" "rm-deps"
"repackage" "re-package"
"syncdeps" "sync-deps"
"version"
"config:"
"lint"
"nocolor" "no-color"
"nobuild" "no-build"
"file:"
"nocheck" "no-check"
"noarchive" "no-archive"
"noprepare" "no-prepare"
"nosign" "no-sign"
"printcontrol" "print-control"
"printsrcinfo" "print-srcinfo"
"sign" 
"skipchecksums" "skip-checksums"
"skippgpcheck" "skip-pgp-check"
"verifysource" "verify-source"
"asdeps" "as-deps"
"allowdowngrades" "allow-downgrades"
"noconfirm" "no-confirm"
"reinstall" "re-install"
"in-fakeroot"
"mprcheck" "durcheck"
"mpr-check" "dur-check"
"passenv" "pass-env" 
"noinstallrecommends" "no-install-recommends"
"installrecommends" "install-recommends"
"noinstallsuggests" "no-install-suggests"
"installsuggests" "install-suggests"
"msg" "msg2" "warning" "warning2" "error" "error2"
)
	  
CLI_ARGS=("${@}")

if ! parseopts "$OPT_SHORT" "${OPT_LONG[@]}" -- "${CLI_ARGS[@]}"; then
	exit $E_INVALID_OPTION
fi
set -- "${OPTRET[@]}"
unset OPT_SHORT OPT_LONG OPTRET

while true; do
	case "$1" in
		# makedeb options.
        --ignorearch|\
		-A|--ignorearch)         IGNOREARCH=1 ;;
        --danger)                DANGER=1 ;;
		-c|--clean)              CLEANUP=1 ;;
		-C|--cleanbuild)         CLEANBUILD=1 ;;
        --nodeps|\
		-d|--no-deps)            NODEPS=1 ;;
        --noextract|\
        -e|--no-extract)         NOEXTRACT=1 ;;
        -f|--force)              FORCE=1 ;;
        --geninteg|\
		-g|--gen-integ)          BUILDPKG=0 GENINTEG=1 IGNOREARCH=1 ;;
		-h|--help)               usage; exit $E_OK ;;
		-H|--field)              shift; CONTROL_FIELDS+=("${1}") ;;
		-i|--install)            INSTALL=1 ;;
        --reinstall)             INSTALL=1; REINSTALL=1;;
		-V|--version)            version; exit $E_OK ;;
        --rmdeps|\
		-r|--rm-deps)            RMDEPS=1 ;;
        --syncdeps|\
		-s|--sync-deps)          SYNCDEPS=1 ;;
		--lint)                  LINTPKGBUILD=1 ;;
		-p|--file)               shift; BUILDFILE="${1}" ;;
		--mpr-check|--dur-check) mpr_check; exit $E_OK ;;
        --no-archive|\
		--noarchive)      NOARCHIVE=1 ;;
        --no-check|\
		--nocheck)        RUN_CHECK='n' ;;
        --no-prepare|\
		--noprepare)      RUN_PREPARE='n' ;;
        --repackage|\
		-R|--re-package)   REPKG=1 ;;
        --nobuild|\
		--no-build)              NOBUILD=1 ;;
        --nocheck|\
		--no-check)              NOCHECK=1 ;;
        --nocolor|\
		--no-color)              NO_COLOR=1 ;;
        --no-sign|\
		--nosign)         SIGNPKG='n' ;;
        --printcontrol |\
		--print-control)         BUILDPKG=0 PRINTCONTROL=1 IGNOREARCH=1 ;;
		--print-function-dir)    echo "${LIBRARY}"; exit 0 ;;
		--print-srcinfo| \
        --printsrcinfo)         BUILDPKG=0 PRINTSRCINFO=1 IGNOREARCH=1 ;;
#		--printsrcinfo)          warning "'--printsrcinfo' will be removed in a future release. Please use '--print-srcinfo' instead.'"; BUILDPKG=0 PRINTSRCINFO=1 IGNOREARCH=1 ;;
		--skippgpcheck|\
        --skip-pgp-check)        SKIPPGPCHECK=1 ;;
		--)                      shift; break ;;

		# APT options.
        --asdeps|\
		--as-deps)               ASDEPS=1 ;;
        --allowdowngrades|\
		--allow-downgrades)      ALLOW_DOWNGRADES=1 ;;
        --noconfirm|\
		--no-confirm)            NOCONFIRM=1 ;;#
        
        
        --noinstallrecommends|\
        --no-install-recommends) RECOMMENDS_PACKAGES='N';;
        
        --installrecommends|\
        --install-recommends) RECOMMENDS_PACKAGES='Y';;
        
        --noinstallsuggests|\
        --no-install-suggests) SUGGESTS_PACKAGES='N';;
        
        --installsuggests|\
        --install-suggests) SUGGESTS_PACKAGES='Y';;
        
		# Sudo options.
        --passenv|\
		--pass-env)              SUDOARGS+=('-E') ;;

		# Message options.
		--msg)                   shift; MAKEDEB_MESSAGES+=("${1}"); MAKEDEB_MESSAGE_TYPES+=('msg') ;;
		--msg2)                  shift; MAKEDEB_MESSAGES+=("${1}"); MAKEDEB_MESSAGE_TYPES+=('msg2') ;;
		--warning)               shift; MAKEDEB_MESSAGES+=("${1}"); MAKEDEB_MESSAGE_TYPES+=('warning') ;;
		--warning2)              shift; MAKEDEB_MESSAGES+=("${1}"); MAKEDEB_MESSAGE_TYPES+=('warning2') ;;
		--error)                 shift; MAKEDEB_MESSAGES+=("${1}"); MAKEDEB_MESSAGE_TYPES+=('error') ;;
		--error2)                shift; MAKEDEB_MESSAGES+=("${1}"); MAKEDEB_MESSAGE_TYPES+=('error2') ;;
		--question)              shift; MAKEDEB_MESSAGES+=("${1}"); MAKEDEB_MESSAGE_TYPES+=('question') ;;
		--no-style)              shift; MAKEDEB_MESSAGES+=("${1}"); MAKEDEB_MESSAGE_TYPES+=('no-style') ;;

		# Internal options.
		--in-fakeroot)           INFAKEROOT=1 ;;

		# Pacstall is trash options.
		#--why-yes-please-i-would-very-much-like-to-use-pacstall-why-would-i-want-to-use-anything-else-i-know-my-taste-is-absolutely-hideous-but-im-fine-with-that-as-i-like-my-programs-being-absolutely-atrocious) DESTROYSYSTEM=1 ;;
	esac
	shift
done

if (( NOCONFIRM == 1 )); then
    APTARGS+=('--yes') 
fi

if (( ALLOW_DOWNGRADES == 1 )); then
    APTARGS+=('--allow-downgrades')
fi

if (( RECOMMENDS_PACKAGES == "Y" )); then
    APTARGS+=('--install-recommends') 
fi

if (( RECOMMENDS_PACKAGES == "N" )); then
    APTARGS+=('--no-install-recommends')
fi

if (( SUGGESTS_PACKAGES == "Y" )); then
    APTARGS+=('--install-suggests') 
fi

if (( SUGGESTS_PACKAGES == "N" )); then
    APTARGS+=('--no-install-suggests')
fi
# attempt to consume any extra argv as environment variables. this supports
# overriding (e.g. CC=clang) as well as overriding (e.g. CFLAGS+=' -g').
extra_environment=()
while [[ $1 ]]; do
	if [[ $1 = [_[:alpha:]]*([[:alnum:]_])?(+)=* ]]; then
		extra_environment+=("$1")
	fi
	shift
done

# setup signal traps
trap 'clean_up' 0
for signal in TERM HUP QUIT; do
	trap "trap_exit $signal \"$(gettext "%s signal caught. Exiting...")\" \"$signal\"" "$signal"
done
trap 'trap_exit INT "$(gettext "Aborted by user! Exiting...")"' INT
trap 'trap_exit USR1 "$(gettext "An unknown error has occurred. Exiting...")"' ERR

load_makepkg_config

# override settings from extra variables on commandline, if any
if (( ${#extra_environment[*]} )); then
	export "${extra_environment[@]}"
fi

# canonicalize paths and provide defaults if anything is still undefined
for var in PKGDEST SRCDEST SRCPKGDEST LOGDEST BUILDDIR; do
	printf -v "$var" '%s' "$(canonicalize_path "${!var:-$startdir}")"
done
unset var

# check if messages are to be printed using color
if [[ -t 2 ]] && ! (( "${NO_COLOR}" )) && check_buildenv "color" "y"; then
	colorize
else
	unset ALL_OFF BOLD BLUE GREEN RED YELLOW
fi


# If we're to print a message, do that and exit.
if [[ "${#MAKEDEB_MESSAGE_TYPES[@]}" -gt "0" ]]; then
	mapfile -t nums < <(seq 0 "$(( "${#MAKEDEB_MESSAGE_TYPES[@]}" - 1 ))")

	for num in "${nums[@]}"; do
		"${MAKEDEB_MESSAGE_TYPES[$num]}" "${MAKEDEB_MESSAGES[$num]}"
	done
	exit 0
fi

# check makepkg.conf for some basic requirements
lint_config || exit $E_CONFIG_ERROR


# check that all settings directories are user-writable
if ! ensure_writable_dir "BUILDDIR" "$BUILDDIR"; then
	plainerr "$(gettext "Aborting...")"
	exit $E_FS_PERMISSIONS
fi

if (( ! (GENINTEG) )) && ! ensure_writable_dir "PKGDEST" "$PKGDEST"; then
	plainerr "$(gettext "Aborting...")"
	exit $E_FS_PERMISSIONS
fi

if ! ensure_writable_dir "SRCDEST" "$SRCDEST" ; then
	plainerr "$(gettext "Aborting...")"
	exit $E_FS_PERMISSIONS
fi

if (( SOURCEONLY )); then
	if ! ensure_writable_dir "SRCPKGDEST" "$SRCPKGDEST"; then
		plainerr "$(gettext "Aborting...")"
		exit $E_FS_PERMISSIONS
	fi

	# If we're only making a source tarball, then we need to ignore architecture-
	# dependent behavior.
	IGNOREARCH=1
fi

if (( LOGGING )) && ! ensure_writable_dir "LOGDEST" "$LOGDEST"; then
	plainerr "$(gettext "Aborting...")"
	exit $E_FS_PERMISSIONS
fi

if (( ! INFAKEROOT )); then
	if (( EUID == 0 )); then
		M10="$(gettext "Running %s as root is not allowed as it can cause permanent,\ncatastrophic damage to your system.")" 
		if (( DANGER == 0 )); then
            error "${M10}" "${makepkg_program_name}"
            exit $E_ROOT
        else 
            warning "${M10}" "${makepkg_program_name}"
        fi
	fi
else
	if [[ -z $FAKEROOTKEY ]]; then
		error "$(gettext "Do not use the %s option. This option is only for internal use by %s.")" "'--in-fakeroot'" "${makepkg_program_name}"
		exit $E_INVALID_OPTION
	fi
fi

# Unset variables from a user's environment variables.
unset pkgname "${pkgbuild_schema_strings[@]}" "${pkgbuild_schema_arrays[@]}"
unset "${known_hash_algos[@]/%/sums}"
unset -f pkgver prepare build check package "${!package_@}"
unset "${!makedepends_@}" "${!depends_@}" "${!source_@}" "${!checkdepends_@}"
unset "${!optdepends_@}" "${!conflicts_@}" "${!provides_@}" "${!replaces_@}"
unset "${!cksums_@}" "${!md5sums_@}" "${!sha1sums_@}" "${!sha224sums_@}"
unset "${!sha256sums_@}" "${!sha384sums_@}" "${!sha512sums_@}" "${!b2sums_@}"

# Read environment variables.
# We don't process variables that start with '_', as those are meant for custom
# user-defined variables.
read_env

# Unset distro-specific environment variables from a user's environment variables.
# This processes distro-specific global variables (i.e. 'jammy_depends') as well
# as architecture-specific ones (i.e. 'jammy_depends_x86_64').
for a in "${pkgbuild_schema_arch_arrays[@]}"; do
	mapfile -t matches < <(printf '%s\n' "${env_keys[@]}" | grep -E "^[^_]*_${a}$|^[^_]*_${a}_")

	for match in "${matches[@]}"; do
		unset "${match}"
	done
done

BUILDFILE=${BUILDFILE:-$BUILDSCRIPT}
if [[ ! -f $BUILDFILE ]]; then
	error "$(gettext "%s does not exist.")" "$BUILDFILE"
	exit $E_PKGBUILD_ERROR

else
	if [[ $(<"$BUILDFILE") = *$'\r'* ]]; then
		error "$(gettext "%s contains %s characters and cannot be sourced.")" "$BUILDFILE" "CRLF"
		exit $E_PKGBUILD_ERROR
	fi

	if [[ ! $BUILDFILE -ef $PWD/${BUILDFILE##*/} ]]; then
		error "$(gettext "%s must be in the current working directory.")" "$BUILDFILE"
		exit $E_PKGBUILD_ERROR
	fi

	if [[ ${BUILDFILE:0:1} != "/" ]]; then
		BUILDFILE="$startdir/$BUILDFILE"
	fi

	source_buildfile "$BUILDFILE"
fi

# Re-read environment variables.
read_env

# Set pkgbase variable if the user didn't define it.
# We don't set to 'pkgbase' yet so that we don't lint that variable when the user didn't set it.
_pkgbase="${pkgbase:-${pkgname[0]}}"

# check the PKGBUILD for some basic requirements
lint_pkgbuild || exit $E_PKGBUILD_ERROR

# Now we can set 'pkgbase'.
pkgbase="${_pkgbase}"

# If 'pkgbase' isn't in env_vars/env_keys, add it now.
if ! in_array pkgbase "${env_keys[@]}"; then
	env_vars+=("pkgbase=${pkgbase}")
	env_keys+=('pkgbase')
fi

# If pkgbase=pacstall or pacstall is in 'pkgname', abort.
# Who would want to ever use Pacstall???
#if ! (( "${DESTROYSYSTEM}" )); then
#	if [[ "${pkgbase}" == "pacstall" ]] || in_array 'pacstall' "${pkgname[@]}"; then
#		error "$(gettext "How dare you! The enemy, the forefront of our demise, the bitter trash that one calls 'Pacstall'.")"
#		error "$(gettext "It's sad to see that you've resorted to this, best of wishes as you reach your ultimatum of doom.")"
#		error "$(gettext "Since you apparently want to go and use Pacstall, go ahead and pass the following to confirm your actions:")"
#		error "'--why-yes-please-i-would-very-much-like-to-use-pacstall-why-would-i-want-to-use-anything-else-i-know-my-taste-is-absolutely-hideous-but-im-fine-with-that-as-i-like-my-programs-being-absolutely-atrocious'"
#		exit 1
#	fi
#fi

# Exit regardless of sucess status if '--lint' was passed.
(( "${LINTPKGBUILD}" )) && exit

if (( !SOURCEONLY && !PRINTSRCINFO )); then
	merge_arch_attrs
fi

basever=$(get_full_version)

if [[ $BUILDDIR -ef "$startdir" ]]; then
	srcdir="$BUILDDIR/src"
	pkgdirbase="$BUILDDIR/pkg"
else
	srcdir="$BUILDDIR/$pkgbase/src"
	pkgdirbase="$BUILDDIR/$pkgbase/pkg"

fi

# set pkgdir to something "sensible" for (not recommended) use during build()
pkgdir="$pkgdirbase/$pkgbase"

if (( GENINTEG )); then
	mkdir -p "$srcdir"
	chmod a-s "$srcdir"
	cd_safe "$srcdir"
	download_sources novcs allarch >&2
	generate_checksums
	exit $E_OK
fi

if have_function pkgver; then
	PKGVERFUNC=1
fi

# check we have the software required to process the PKGBUILD
check_software || exit $E_MISSING_MAKEPKG_DEPS

if (( ${#pkgname[@]} > 1 )) || have_function package_${pkgname}; then
	SPLITPKG=1
fi

# test for available PKGBUILD functions
if have_function prepare; then
	# "Hide" prepare() function if not going to be run
	if [[ $RUN_PREPARE != "n" ]]; then
		PREPAREFUNC=1
	fi
fi
if have_function build; then
	BUILDFUNC=1
fi
if have_function check; then
	# "Hide" check() function if not going to be run
	if [[ $RUN_CHECK = 'y' ]] || { ! check_buildenv "check" "n" && [[ $RUN_CHECK != "n" ]]; }; then
		CHECKFUNC=1
	fi
fi
if have_function package; then
	PKGFUNC=1
fi

# check if gpg signature is to be created and if signing key is valid
if { [[ -z $SIGNPKG ]] && check_buildenv "sign" "y"; } || [[ $SIGNPKG == 'y' ]]; then
	SIGNPKG='y'
	if ! gpg --list-secret-key ${GPGKEY:+"$GPGKEY"} &>/dev/null; then
		if [[ ! -z $GPGKEY ]]; then
			error "$(gettext "The key %s does not exist in your keyring.")" "${GPGKEY}"
		else
			error "$(gettext "There is no key in your keyring.")"
		fi
		exit $E_PRETTY_BAD_PRIVACY
	fi
fi

if (( PACKAGELIST )); then
	print_all_package_names
	exit $E_OK
fi

if (( PRINTSRCINFO )); then
	write_srcinfo
	exit $E_OK
fi

# Process distro-specific dependencies.
check_distro_dependencies

# Convert needed dependencies.
convert_dependencies
pkgarch=$(get_pkg_arch)
remove_optdepends_description recommends "${recommends[@]}"
remove_optdepends_description suggests "${suggests[@]}"

convert_relationships predepends "${predepends[@]}"
convert_relationships depends "${depends[@]}"
convert_relationships makedepends "${makedepends[@]}"
convert_relationships checkdepends "${checkdepends[@]}"
convert_relationships recommends "${recommends[@]}"
convert_relationships suggests "${suggests[@]}"
convert_relationships conflicts "${conflicts[@]}"
convert_relationships provides "${provides[@]}"
convert_relationships replaces "${replaces[@]}"
convert_relationships breaks "${breaks[@]}"

if (( PRINTCONTROL )); then
	output=""

	for pkg in "${pkgname[@]}"; do
		output+="$(pkgname="${pkg}" write_control_info)"
		output+=$'\n\n'
	done

	echo -n "${output}" | head -n -1
	exit $E_OK
fi

if (( ! PKGVERFUNC )); then
	check_build_status
fi

# Run the bare minimum in fakeroot
if (( INFAKEROOT )); then
	if (( SOURCEONLY )); then
		create_srcpackage
		msg "$(gettext "Leaving %s environment.")" "fakeroot"
		exit $E_OK
	fi
	
	# Load up extensions for use by 'package()' and post-install scripts.
	load_extensions

	chmod 755 "$pkgdirbase"
	if (( ! SPLITPKG )); then
		run_single_packaging
	else
		run_split_packaging
	fi

	create_debug_package

	msg "$(gettext "Leaving %s environment.")" "fakeroot"
	exit $E_OK
fi

msg "$(gettext "Making package: %s")" "$pkgbase $basever ($(date +%c))"

# if we are creating a source-only package, go no further
if (( SOURCEONLY )); then
	if [[ -f $SRCPKGDEST/${pkgbase}-${basever}${SRCEXT} ]] \
			&& (( ! FORCE )); then
		error "$(gettext "A source package has already been built. (use %s to overwrite)")" "-f"
		exit $E_ALREADY_BUILT
	fi

	# Get back to our src directory so we can begin with sources.
	mkdir -p "$srcdir"
	chmod a-s "$srcdir"
	cd_safe "$srcdir"
	if (( SOURCEONLY == 2 )); then
		download_sources allarch
	elif ( (( ! SKIPCHECKSUMS )) || \
			( (( ! SKIPPGPCHECK )) && source_has_signatures ) ); then
		download_sources allarch novcs
	fi
	check_source_integrity all
	cd_safe "$startdir"

	enter_fakeroot

	if [[ $SIGNPKG = 'y' ]]; then
		msg "$(gettext "Signing package...")"
		create_signature "$SRCPKGDEST/${pkgbase}-$(get_full_version)${SRCEXT}"
	fi

	msg "$(gettext "Source package created: %s")" "$pkgbase ($(date +%c))"
	exit $E_OK
fi

# Check for missing dependencies.
if (( NODEPS || ( VERIFYSOURCE && !SYNCDEPS ) )); then
	if (( NODEPS )); then
		warning "$(gettext "Skipping dependency checks.")"
	fi
else 
	msg "$(gettext "Checking for missing dependencies...")"
	# We need to tell our call to the Python script where makedeb is located because we might need to call it in order to print messages.
	#
	# TODO: perl script works fine, nothing to do
	# On Ubuntu 20.04, do *not* have libgcc1 installed, but *do* have libgcc-s1 installed.
	# Running 'apt-get satisfy libgcc1' works as expected, as libgcc-s1 provides libgcc1.
	# On the other hand, attempting to view the provided package list for libgcc1 isn't showing
	# libgcc-s1 anywhere. On that note, we gotta be a bit more cautious with the results of our
	# script, and put more checks into place, such as checking if we actually installed any new
	# packages before running 'apt-mark auto'.    
	if (( "${SYNCDEPS}" )); then
        additional=()
        if (( RECOMMENDS_PACKAGES == "Y" )); then
            additional+=("${recommends[@]}")
        fi
        
        if (( SUGGESTS_PACKAGES == "Y" )); then
            additional+=("${suggests[@]}")
        fi
        install_missing_dependencies "${additional[@]}" "${predepends[@]}" "${depends[@]}" "${makedepends[@]}" "${checkdepends[@]}"
    else
        verify_no_missing_dependencies "${predepends[@]}" "${depends[@]}" "${makedepends[@]}" "${checkdepends[@]}"
    fi
    
    if (( $? != 0 )); then 
        exit "${E_INSTALL_DEPS_FAILED}"
    fi
    
	unset missing_deps dep
fi

# Load up extensions for use by 'build()'.
msg "$(gettext "Loading extensions...")"
load_extensions

# Get back to our src directory so we can begin with sources.
mkdir -p "$srcdir"
chmod a-s "$srcdir"
cd_safe "$srcdir"

if (( !REPKG )); then
	if (( NOEXTRACT && ! VERIFYSOURCE )); then
		warning "$(gettext "Using existing %s tree")" "\$srcdir/"
	else
		download_sources
		check_source_integrity
		(( VERIFYSOURCE )) && exit $E_OK

		if (( CLEANBUILD )); then
			msg "$(gettext "Removing existing %s directory...")" "\$srcdir/"
			rm -rf "$srcdir"/*
		fi

		extract_sources
		if (( PREPAREFUNC )); then
			run_prepare
		fi
		if (( REPRODUCIBLE )); then
			# We have activated reproducible builds, so unify source times before
			# building
			find "$srcdir" -exec touch -h -d @$SOURCE_DATE_EPOCH {} +
		fi
	fi

	if (( PKGVERFUNC )); then
		update_pkgver
		basever=$(get_full_version)
		check_build_status
	fi
fi

# clean existing pkg directory
if [[ -d $pkgdirbase ]]; then
	msg "$(gettext "Removing existing %s directory...")" "\$pkgdir/"
	rm -rf "$pkgdirbase"
fi
mkdir -p "$pkgdirbase"
chmod a-srw "$pkgdirbase"
cd_safe "$startdir"

prepare_buildenv

if (( ! REPKG )); then
	(( BUILDFUNC )) && run_build
	(( CHECKFUNC )) && run_check
	cd_safe "$startdir"
fi

enter_fakeroot

create_package_signatures || exit $E_PRETTY_BAD_PRIVACY

# if inhibiting archive creation, go no further
if (( NOARCHIVE )); then
	msg "$(gettext "Package directory is ready.")"
#	exit $E_OK
else 
    msg "$(gettext "Finished making: %s")" "$pkgbase $basever ($(date +%c))"
fi
# Remove installed build dependencies.
if (( "${RMDEPS}" )); then
	msg "$(gettext "Removing unneeded dependencies...")"
	if ! sudo apt-get autoremove "${APTARGS[@]}"; then
		error "$(gettext "Failed to remove dependencies.")"
		exit "${E_REMOVE_DEPS_FAILED}"
	fi
fi


install_package #&& exit $E_OK || exit $E_INSTALL_FAILED
