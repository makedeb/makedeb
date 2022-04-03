CONFIG_FILE = $(shell cat .data.json)
MAKEDEB_MAN_EPOCH = $(shell echo '$(CONFIG_FILE)' | jq -r '.makedeb_man_epoch')
PKGBUILD_MAN_EPOCH = $(shell echo '$(CONFIG_FILE)' | jq -r '.pkgbuild_man_epoch')
CURRENT_VERSION = $(shell echo '$(CONFIG_FILE)'  | jq -r -r '. | .current_pkgver + "-" + .current_pkgrel')

.ONESHELL:

all:
	true

prepare:
	# makedeb.
	cd src/
	sed -i 's|$$$${MAKEDEB_VERSION}|$(CURRENT_VERSION)|' main.sh
	sed -i 's|$$$${MAKEDEB_RELEASE}|$(RELEASE)|' main.sh
	sed -i 's|$$$${MAKEDEB_INSTALLATION_SOURCE}|$(TARGET)|' main.sh
	find ./main.sh functions/ -type f -exec sed -i 's|^.*# COMP_RM$$||' '{}' \;
	cd ../../
	
	# man pages.
	sed -i 's|$$$${pkgver}|$(CURRENT_VERSION)|' man/makedeb.8.adoc
	sed -i 's|$$$${pkgver}|$(CURRENT_VERSION)|' man/pkgbuild.5.adoc

package:
	# makedeb.
	install -Dm 644 ./completions/makedeb.bash '$(DESTDIR)/usr/share/bash-completion/completions/makedeb'
	
	cd src/
	install -Dm 755 ./makepkg.sh '$(DESTDIR)/usr/bin/makedeb-makepkg'
	
	cd functions/
	find ./ -type f -exec install -Dm 755 '{}' '$(DESTDIR)/usr/share/makedeb-makepkg/{}' \;
	cd ../
	
	install -Dm 644 ./makepkg.conf '$(DESTDIR)/etc/makepkg.conf'
	install -Dm 755 ./makepkg-template '$(DESTDIR)/usr/bin/makepkg-template'
	
	cd ../../
	
	# man pages
	export SOURCE_DATE_EPOCH="$(MAKEDEB_MAN_EPOCH)"
	asciidoctor -b manpage man/makedeb.8.adoc -o "$(DESTDIR)/usr/share/man/man8/makedeb.8"
	
	export SOURCE_DATE_EPOCH="$(PKGBUILD_MAN_EPOCH)"
	asciidoctor -b manpage man/pkgbuild.5.adoc -o "$(DESTDIR)/usr/share/man/man5/pkgbuild.5"

# This is for use by dpkg-buildpackage. Please use prepare and package instead.
install:
	$(MAKE) prepare RELEASE=alpha TARGET=apt
	$(MAKE) package DESTDIR="$(DESTDIR)" TARGET=apt

