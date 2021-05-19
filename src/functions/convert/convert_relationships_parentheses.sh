convert_relationships_parentheses() {
  for i in new_depends new_optdepends new_conflicts; do
    export ${i}="$(eval echo \${$i} | sed 's|[<>=][<>=]|& |g')"
  done

  for i in new_makedepends new_checkdepends; do
    export ${i}="$(eval echo \${$i} | sed 's|([<>=][<>=][0-9.\-]*)||g')"
  done
}
