.PHONY: build

build: clean
	bash ./build.sh

commit: 
	git add --all
	git commit -m "update"
	git push

clean:
	rm -fR ./build

install: clean
	bash ./build.sh --reinstall
