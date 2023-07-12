build: clean
	bash ./scripts/build.sh --noextract --nodeps --danger --allow-downgrades
install: clean
	bash ./scripts/build.sh --noextract --nodeps --danger --reinstall --noconfirm --allow-downgrades
clean:
	rm -fR ./build
fixmod:
	bash ./scripts/fixmod.sh
gen-po:
	bash ./scripts/gen-po.sh
commit: fixmod
	bash ./scripts/commit.sh
pkgbuild:
	bash ./scripts/pkgbuild.sh > ./PKGBUILD/TEMPLATE.PKGBUILD


