build: clean
	bash ./scripts/build.sh --noextract --nodeps --danger
install: clean
	bash ./scripts/build.sh --noextract --nodeps --danger --reinstall
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


