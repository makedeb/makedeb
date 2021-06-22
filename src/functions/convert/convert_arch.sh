convert_arch() {
  if [[ ${arch} == "x86_64" ]]; then
    msg2 "Converting architecure..."
    export makedeb_arch="amd64"
  elif [[ ${arch} == "armv7l" ]]; then
    msg2 "Converting architecure..."
    export makedeb_arch="armhf"
  elif [[ ${arch} == "any" ]]; then
    msg2 "Converting architecure..."
    export makedeb_arch="all"
  fi
}
