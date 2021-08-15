generate_control() {
  local file="${1}"

  local maintainer="$(cat "${file}" | grep '\# Maintainer\:' | sed 's/# Maintainer: //' | xargs | sed 's|>|>,|g' | rev | sed 's|,||' | rev)"

  export_control "Package:" "${pkgname}"
  export_control "Version:" "${makedeb_package_version}"
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

  echo
}
