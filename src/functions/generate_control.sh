generate_control() {
    msg2 "Generating control file..."
    export_control "Package:" "${pkgname}"
    export_control "Description:" "${pkgdesc}"
    export_control "Source:" "${url}"
    export_control "Version:" "${pkgver}"

    export_control "Architecture:" "${makedeb_arch}"
    export_control "License:" "${license[@]}"

    export_control "Maintainer:" "$(cat ../../${FILE} | grep '\# Maintainer\:' | sed 's/# Maintainer: //' | xargs | sed 's|>|>,|g' | rev | sed 's|,||' | rev)"
    
    eval export_control "Depends:" "${new_depends[@]}"
    eval export_control "Suggests:" "${new_optdepends[@]}"
    eval export_control "Conflicts:" "${new_conflicts[@]}"
    eval export_control "Provides:" "${new_provides[@]}"
    eval export_control "Replaces:" "${new_replaces[@]}"
    eval export_control "Breaks:" "${new_replaces[@]}"

    add_extra_control_fields

    echo "" >> DEBIAN/control
}
