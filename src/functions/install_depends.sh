install_depends() {
  if [[ "$(eval echo \${$1})" != "" ]]; then
    echo "Checking ${2} dependencies. One second..."
    for package in "$(eval echo \${${1}[@]})"; do
      if [[ "$(apt list ${package} 2> /dev/null | sed 's/Listing...//g')" == "" ]]; then
        unknown_pkg+=" ${package}"
      fi
    done

    if [[ "${unknown_pkg}" != "" ]]; then
      echo "Couldn't find the following packages:${unknown_pkg[@]}"
      exit 1
    fi

    ${2}_packages="$(apt list $(eval echo \${$1}) 2> /dev/null | sed 's/Listing...//g' | grep -E "$(dpkg --print-architecture)|all" | grep -v "installed" | awk -F/ '{print $1}')"
    if [[ "$(eval echo \${${2}_packages})" != "" ]]; then
      echo "Installing ${2} dependencies..."
      if ! sudo apt install $(eval echo \${${2}_packages}); then
        echo "Couldn't install packages."
        exit 1
      fi
    fi
  fi
}
