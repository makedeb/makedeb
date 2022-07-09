CONFIG_FILE = $(shell cat .data.json)
CURRENT_VERSION = $(shell echo '$(CONFIG_FILE)'  | jq -r -r '. | .current_pkgver + "-" + .current_pkgrel_$(RELEASE)')
FILESYTEM_PREFIX ?=

.ONESHELL:

all:
	true

prepare:
	# makedeb.
	cd src/
	sed -i 's|{MAKEDEB_VERSION}|$(CURRENT_VERSION)|' main.sh
	sed -i 's|{MAKEDEB_RELEASE}|$(RELEASE)|' main.sh
	sed -i 's|{MAKEDEB_INSTALLATION_SOURCE}|$(TARGET)|' main.sh
	sed -i 's|{FILESYSTEM_PREFIX}|$(FILESYSTEM_PREFIX)|' main.sh
	find ./main.sh functions/ -type f -exec sed -i 's|^.*# COMP_RM$$||' '{}' \;
	cd ../
	
	# man pages.
	sed -i 's|$$$${pkgver}|$(CURRENT_VERSION)|' man/makedeb.8.adoc
	sed -i 's|$$$${pkgver}|$(CURRENT_VERSION)|' man/pkgbuild.5.adoc

package:
	# makedeb.
	install -Dm 644 ./completions/makedeb.bash '$(DESTDIR)/usr/share/bash-completion/completions/makedeb'
	
	cd src/
	install -Dm 755 ./main.sh '$(DESTDIR)/usr/bin/makedeb'
	
	cd functions/
	find ./ -type f -exec install -Dm 755 '{}' '$(DESTDIR)/usr/share/makedeb/{}' \;
	cd ../
	
	cd ../extensions/
	find ./ -type f -exec install -Dm 644 '{}' '$(DESTDIR)/usr/lib/makedeb/{}' \;
	cd ../
	
	install -Dm 644 ./makepkg.conf '$(DESTDIR)/etc/makepkg.conf'
	install -Dm 755 ./makepkg-template '$(DESTDIR)/usr/bin/makepkg-template'
	
	cd ../
	
	# man pages
	asciidoctor -b manpage man/makedeb.8.adoc -o "$(DESTDIR)/usr/share/man/man8/makedeb.8"
	asciidoctor -b manpage man/makedeb-extension.5.adoc -o "$(DESTDIR)/usr/share/man/man5/makedeb-extension.5"
	asciidoctor -b manpage man/pkgbuild.5.adoc -o "$(DESTDIR)/usr/share/man/man5/pkgbuild.5"

# This is for use by dpkg-buildpackage. Please use prepare and package instead.
install:
	$(MAKE) prepare RELEASE=alpha TARGET=apt
	$(MAKE) package DESTDIR="$(DESTDIR)" TARGET=apt

