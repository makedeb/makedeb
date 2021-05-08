help() {
  echo "makedeb"
  echo "Usage: makedeb [options]"
  echo
  echo "makedeb takes PKGBUILD files and compiles APT-installable archives."
  echo
  echo "Options:"
  echo "  Items must be space-separated, i.e. '-I -F'"
  echo
  echo "  --help - bring up this help menu"
  echo "  -I, --install - automatically install after building"
  echo "  -F, --file, -p - specify a build file other than 'PKGBUILD'"
  echo "  -B, --prebuilt - make a Debian package from a prebuilt Arch package; Requires a build file to be present"
  echo
  echo "  -C, --skip-conversion - skip conversion of dependencies and architectures"
  echo
  echo "Report bugs at https://github.com/hwittenborn/makedeb"
}
