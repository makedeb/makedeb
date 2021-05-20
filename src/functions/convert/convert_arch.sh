convert_arch() {
  if [[ ${arch} == "x86_64" ]]; then
    echo "Converting architecure..."
    export makedeb_arch="amd64"
  elif [[ ${arch} == "armv7l" ]]; then
    echo "Converting architecure..."
    export makedeb_arch="armhf"
  elif [[ ${arch} == "any" ]]; then
    echo "Converting architecure..."
    export makedeb_arch="all"
  fi
}
