convert_arch() {
  if [[ ${arch} == "x86_64" ]]; then
    export makedeb_arch="amd64"
  elif [[ ${arch} == "armv7l" ]]; then
    export makedeb_arch="armhf"
  elif [[ ${arch} == "any" ]]; then
    export makedeb_arch="all"
  fi
}
