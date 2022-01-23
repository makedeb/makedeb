# This function should be run from the directory containing the 'DEBIAN' folder.
build_deb() {
  local pkgname="${1}" \
        tar_control_arguments \
        tar_data_arguments

  # Generate control.tar.gz archive.
  cd DEBIAN/
  mapfile -t tar_control_arguments < <(find ./ | grep -v '^\./$')
  tar -czf ./control.tar.gz "${tar_control_arguments[@]}"
  cd ..

  # Generate data.tar.gz archive.
  mapfile -t tar_data_arguments < <(find ./ -maxdepth 1 | grep -v '^\./$' | grep -v '^\./DEBIAN$')

  # Tar will freak out if we don't supply any directories here (which will
  # happen when no items were created in ${pkgdir}), so we create the file
  # with no data when such a scenario arrises.
  if [[ "${tar_data_arguments}" != "" ]]; then
    tar -czf data.tar.gz "${tar_data_arguments[@]}"
  else
    printf '' | tar -czf data.tar.gz --files-from -
  fi

  # Create the debian-binary file.
  echo "2.0" > debian-binary

  # Move control.tar.gz from DEBIAN/ to pkgdir.
  mv ./DEBIAN/control.tar.gz ./control.tar.gz

  # Create the .deb package, and remove extra files we created.
  ar -rU "${pkgname}_${pkgver}_${MAKEDEB_CARCH}.deb" debian-binary control.tar.gz data.tar.gz &> /dev/null
  rm debian-binary control.tar.gz data.tar.gz
}
