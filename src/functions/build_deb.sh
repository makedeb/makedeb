# This function should be run from the directory containing the 'DEBIAN' folder.
build_deb() {
  local pkgname="${1}"

  cd DEBIAN/

  # Run 'eval' with literal quotes around directories in find command so
  # directories containing spaces are still passed as a single argument.
  eval tar -czf ../control.tar.gz $(find ./ | grep -v '^\./$' | grep -o '^\./[^/]*' | sort -u | sed "s|.*|'&'|")
  cd ..

  local control_data_dirs="$(find ./ | grep -v '^\./$' | grep -v '^\./DEBIAN' | grep -v 'control\.tar\.gz' | grep -o '^\./[^/]*' | sort -u | sed "s|.*|'&'|")"

  if [[ "${control_data_dirs}" != "" ]]; then
    eval tar -czf data.tar.gz ${control_data_dirs}
  else
    printf '' | tar -czf data.tar.gz --files-from -
  fi

  unset control_data_dirs

  echo "2.0" > debian-binary

  ar r "${pkgname}_${pkgver}_${makedeb_arch}.deb" debian-binary control.tar.gz data.tar.gz &> /dev/null

  rm debian-binary control.tar.gz data.tar.gz
}
