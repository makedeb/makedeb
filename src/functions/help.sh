help() {
  echo "makedeb"
  echo "Usage: makedeb [options]"
  echo
  echo "makedeb takes PKGBUILD files and builds archives installable with APT."
  echo
  echo "Options:"
  echo "  Items must be space-separated, i.e. '-i -B'"
  echo
  echo "  -B, --prebuilt - make a Debian package from a prebuilt Arch package; Still requires a build file to be present"
  echo "  -C, --convert - Attempt to convert and modify Arch Linux dependencies in build file to align with Debian"
  echo "  -F, --file, -p - specify a build file other than 'PKGBUILD'"
  echo "  -h, --help - bring up this help menu"
  echo "  -i, --install - automatically install after building"
  echo "  -P, --pkgname - specify the pkgname for prebuilt packages (--prebuilt) when 'pkgname' is an array"
  echo
  echo "The following options can be passed to makepkg:"
  echo "  --printsrcinfo - print a generated .SRCINFO file and exit"
  echo
  echo "Report bugs at https://github.com/hwittenborn/makedeb"
}
