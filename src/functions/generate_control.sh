generate_control() {
    msg2 "Generating control file..."

	generate_optdepends_fields

	local maintainer="$(cat ../../${FILE} | grep '\# Maintainer\:' | sed 's/# Maintainer: //' | xargs | sed 's|>|>,|g' | rev | sed 's|,||' | rev)"

    export_control "Package:" "${pkgname}"
	export_control "Version:" "${built_archive_version}"
    export_control "Description:" "${pkgdesc}"
	export_control "Architecture:" "${makedeb_arch}"
	export_control "License:" "${license}"
	export_control "Maintainer:" "${maintainer}"
    export_control "Homepage:" "${url}"

    eval export_control "Depends:" "${depends[@]@Q}"
	eval export_control "Recommends:" "${recommends[@]@Q}"
    eval export_control "Suggests:" "${suggests[@]@Q}"
    eval export_control "Conflicts:" "${conflicts[@]@Q}"
    eval export_control "Provides:" "${provides[@]@Q}"
    eval export_control "Replaces:" "${replaces[@]@Q}"
    eval export_control "Breaks:" "${replaces[@]@Q}"

    add_extra_control_fields

    echo "" >> DEBIAN/control
}
