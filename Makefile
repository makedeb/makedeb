all:
	# Install predependencies makedeb needs to properly build itself.
	sudo apt install -qqy python3-apt

	# Get variables
	pkgver="$(cat 'src/PKGBUILD' | grep '^pkgver=' | awk -F '=' '{print $2}')"

	# Copy PKGBUILD
	rm 'src/PKGBUILD'
	cp "PKGBUILDs/LOCAL/STABLE.PKGBUILD" "src/PKGBUILD"

	# Configure PKGBUILD
	sed -i "s|pkgver={pkgver}|pkgver=${pkgver}|" 'src/PKGBUILD'

	# Build makedeb
	cd src
	./makedeb.sh --sync-deps --no-confirm

clean:
	echo "nothing to clean"

install:
	sudo dpkg -i ./makedeb-stable_${pkgver}-1_all.deb
