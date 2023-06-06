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
	git add --all
	git commit -m "update"
	git push
pkgbuild:
	bash ./PKGBUILD/pkgbuild.sh > ./PKGBUILD/TEMPLATE.PKGBUILD


