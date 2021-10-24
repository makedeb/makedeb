GITDIR=$(git rev-parse --show-toplevel)
FOLDERNAME=$(basename "${GITDIR}")
BINDIR := /usr/bin

.ONESHELL:

all:

	# Get variables
	#pkgver="$(cat 'src/PKGBUILD' | grep '^pkgver=' | awk -F '=' '{print $2}')"
	pkgver="7.1.2+bugfix1-1"

	# Set package version and release type
	sed -i "s|makedeb_package_version=.*|makedeb_package_version=${pkgver}-1|" "src/makedeb.sh"
	sed -i "s|makedeb_release_type=.*|makedeb_release_type=STABLE|" "src/makedeb.sh"

	# Remove prebuild commands
	sed -i 's|.*# REMOVE AT PACKAGING||g' "src/makedeb.sh"


clean:
	echo "nothing to clean"

install:
	# Create single file for makedeb
	mkdir -p "${DESTDIR}/usr/bin"

	# Add bash shebang
	echo '#!/usr/bin/env bash' > "${DESTDIR}/usr/bin/makedeb"

	# Copy functions
	find src/functions/ -type f -exec cat '{}' \; >> "${DESTDIR}/usr/bin/makedeb"

	#cp -R "src/functions/" "${DESTDIR}/usr/bin/makedeb"

	cat "src/makedeb.sh" >> "${DESTDIR}/usr/bin/makedeb"
	chmod 555 "${DESTDIR}/usr/bin/makedeb"

	# Copy over extra utilities.
	cd ./src/utils
	find ./ -type f -exec install -Dm 755 '{}' "${DESTDIR}/usr/share/makedeb/utils/{}" \;
	cd ../../

	# Set up man pages
 	SOURCE_DATE_EPOCH="$(git log -1 --pretty='%ct' man/makedeb.8.adoc)" \
    	  asciidoctor -b manpage man/makedeb.8.adoc \
		      -o "${DESTDIR}/usr/share/man/man8/makedeb.8"

	SOURCE_DATE_EPOCH="$(git log -1 --pretty='%ct' man/pkgbuild.5.adoc)" \
	  asciidoctor -b manpage man/pkgbuild.5.adoc \
		      -o "${DESTDIR}/usr/share/man/man5/pkgbuild.5"
