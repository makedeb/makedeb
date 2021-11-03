MAKEDEB_MAN_EPOCH = $(shell stat '--printf=\%Y' man/makedeb.8.adoc)
PKGBUILD_MAN_EPOCH = $(shell stat 'printf=\%Y' man/pkgbuild.5.adoc)
CURRENT_VERSION = $(shell cat .data.json  | jq -r '. | .current_pkgver + "-" + .current_pkgrel')

.ONESHELL:

all:
	true

prepare:
	sed -i 's|$$$${pkgver}|$(PKGVER)|' src/makedeb.sh
	sed -i 's|$$$${release}|$(RELEASE)|' src/makedeb.sh
	sed -i 's|$$$${target}|$(TARGET)|' src/makedeb.sh
	find src/makedeb.sh src/functions/ -type f -exec sed -i 's|^.*# REMOVE AT PACKAGING$$||' '{}' \;
	
	sed -i 's|$$$${pkgver}|$(PKGVER)|' man/makedeb.8.adoc
	sed -i 's|$$$${pkgver}|$(PKGVER)|' man/pkgbuild.5.adoc

package:
	mkdir -p "$(DESTDIR)/usr/bin"
	echo '#!/usr/bin/env bash' > "$(DESTDIR)/usr/bin/makedeb"
	find src/functions/ -type f -exec cat '{}' \; >> "$(DESTDIR)/usr/bin/makedeb"
	cat "src/makedeb.sh" >> "$(DESTDIR)/usr/bin/makedeb"
	chmod 755 "$(DESTDIR)/usr/bin/makedeb"
	
	cd ./src/utils
	find ./ -type f -exec install -Dm 755 '{}' "$(DESTDIR)/usr/share/makedeb/utils/{}" \;
	cd ../../
	
	export SOURCE_DATE_EPOCH="$(MAKEDEB_MAN_EPOCH)"
	asciidoctor -b manpage man/makedeb.8.adoc -o "$(DESTDIR)/usr/share/man/man8/makedeb.8"
	
	export SOURCE_DATE_EPOCH="$(PKGBUILD_MAN_EPOCH)"
	asciidoctor -b manpage man/pkgbuild.5.adoc -o "$(DESTDIR)/usr/share/man/man5/pkgbuild.5"

# This is for use by dpkg-buildpackage. Please use prepare and package instead.
install:
	$(MAKE) prepare PKGVER="$(LATEST_STABLE_VERSION)" RELEASE=stable TARGET=local
	$(MAKE) package DESTDIR="$(DESTDIR)"

