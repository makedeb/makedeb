clean(){
    rm -fR ./build
}

build(){
    clean
    rm -fR ./build
	srcdir="$(pwd)/build/src"
	mkdir -p ${srcdir} 
	. ./PKGBUILD/TEMPLATE.PKGBUILD
	ln -s ../PKGBUILD/TEMPLATE.PKGBUILD ./build/PKGBUILD
	ln -s ../../ ./build/src/"${pkgname}"
    
    cd ./build
	bash ../src/main.sh "${@}"
	cd ..
}

fixmod(){
    shopt -s globstar
	chmod 644 .gitignore
	for i in ./**; do 
        if [ -d "$i" ]; then 
            chmod 755 "$i"; 
        else   
            chmod 644 "$i"; 
        fi; 
    done
}

pkgbuild(){
    bash ./PKGBUILD/pkgbuild.sh > ./PKGBUILD/TEMPLATE.PKGBUILD
}

commit(){
    fixmod
    git add --all
	git commit -m "update"
	git push
}

_command="$1"
shift;
"${_command}" "${@}"

#
