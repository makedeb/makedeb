convert_relationships_parentheses() {
  # Formats versions to work with Debian control file
  for i in depends optdepends conflicts makedepends checkdepends provides replaces; do
    eval declare -g "${i}=($(eval echo "\${$i[@]@Q}" | sed 's|(| (|g' | sed -E 's/[<>=][<>=]|[<>=]/& /g'))"
  done
}
