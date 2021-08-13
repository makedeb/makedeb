convert_arch() {
  msg "Converting architecure..."

  if [[ "${arch}" == "any" ]]; then
    export makedeb_arch="all"
    export makepkg_arch="any"
    export package_extension="pkg.tar.zst"

  else
    export makepkg_arch="$(uname -m)"

    if [[ "${makepkg_arch}" == "x86_64" ]]; then
      export makedeb_arch="amd64"
      export package_extension="pkg.tar.zst"

    elif [[ "${makepkg_arch}" == "armv7l" ]]; then
      export CARCH="armv7h"
      export makepkg_arch="armv7h"
      export makedeb_arch="armhf"

      if [[ "${target_os}" == "debian" ]]; then
        export package_extension="pkg.tar.zst"
      elif [[ "${target_os}" == "arch" ]]; then
        export package_extension="pkg.tar.xz"
      fi

    elif [[ "${makepkg_arch}" == "aarch64" ]]; then
      export CARCH="aarch64"
      export makepkg_arch="aarch64"
      export makedeb_arch="arm64"

      if [[ "${target_os}" == "debian" ]]; then
        export package_extension="pkg.tar.zst"
      elif [[ "${target_os}" == "arch" ]]; then
        export package_extension="pkg.tar.xz"
      fi

    elif [[ "${makepkg_arch}" == "armv6l" ]]; then
      export CARCH="armv6l"
      export makepkg_arch="armv6l"
      export makedeb_arch="armhf"

      if [[ "${target_os}" == "debian" ]]; then
        export package_extension="pkg.tar.zst"
      elif [[ "${target_os}" == "arch" ]]; then
        export package_extension="pkg.tar.xz"
      fi
    fi
  fi
}
