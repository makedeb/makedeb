build: clean
	bash ./build.sh

fixmod:
	bash ./fixmod.sh

commit: fixmod
	git add --all
	git commit -m "update"
	git push

clean:
	rm -fR ./build

pkgbuild:
	bash ./PKGBUILD/pkgbuild.sh > ./PKGBUILD/TEMPLATE.PKGBUILD

install: clean
	bash ./build.sh --reinstall


