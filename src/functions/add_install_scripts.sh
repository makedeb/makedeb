add_install_scripts() {
  if ! [[ -f ".INSTALL" ]]; then
    return 0
  fi

  msg2 "Converting installation scripts..."
  source .INSTALL

  for i in pre_install post_install pre_remove post_remove; do
    if [[ "$(type -t "${i}")" != "function" ]]; then
      continue
    fi

    function_data="$(type "${i}" | sed '1,3d' | sed '$d')"

    output_filename="$(echo "${i}" | sed 's|_install|inst|' | sed 's|_remove|rm|')"

    echo '#!/usr/bin/env bash' > "DEBIAN/${output_filename}"
    echo "${function_data}" >> "DEBIAN/${output_filename}"
    chmod 555 "DEBIAN/${output_filename}"
  done
}
