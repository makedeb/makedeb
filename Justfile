build:
	bash ./scripts.sh build --noextract --nodeps --danger
install: 
	bash ./scripts.sh build --noextract --nodeps --danger --reinstall
clean:
	bash ./scripts.sh clean
fixmod:
	bash ./scripts.sh fixmod
commit:
	bash ./scripts.sh commit
pkgbuild:
	bash ./scripts.sh pkgbuild

