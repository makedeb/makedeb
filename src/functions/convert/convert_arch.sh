convert_arch() {
  if [[ ${result_arch} == "x86_64" ]]; then
    echo "Converting architecure..."
    export makedeb_arch="amd64"
  elif [[ ${result_arch} == "armv7l" ]]; then
    echo "Converting architecure..."
    export makedeb_arch="armhf"
  elif [[ ${result_arch} == "any" ]]; then
    echo "Converting architecure..."
    export makedeb_arch="all"
  fi
}
