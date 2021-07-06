remove_depends() {
  if [[ "${apt_package_dependencies}" != "" ]]; then
    msg "Removing build dependencies..."

    eval sudo apt purge ${apt_package_dependencies}
  fi
}
