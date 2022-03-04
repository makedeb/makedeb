# This function should be run from the directory containing the 'DEBIAN' folder.
zstdthreads="0"
zstdlevel="10"
build_deb() {
  local pkgname="${1}" \
        tar_control_arguments \
        tar_data_arguments

  # Generate control.tar.zst archive.
  cd DEBIAN/
  mapfile -t tar_control_arguments < <(find ./ | grep -v '^\./$')
  tar -cf ./control.tar "${tar_control_arguments[@]}"
  zstd "-T${zstdthreads}" "-${zstdlevel}" --rm -q control.tar
  cd ..

  # Generate data.tar.zst archive.
  mapfile -t tar_data_arguments < <(find ./ -maxdepth 1 | grep -v '^\./$' | grep -v '^\./DEBIAN$')

  # Tar will freak out if we don't supply any directories here (which will
  # happen when no items were created in ${pkgdir}), so we create the file
  # with no data when such a scenario arrises.
  if [[ "${tar_data_arguments}" != "" ]]; then
    tar -cf data.tar "${tar_data_arguments[@]}"
  else
    printf '' | tar -cf data.tar --files-from -
  fi
  zstd "-T${zstdthreads}" "-${zstdlevel}" --rm -q data.tar
  # Create the debian-binary file.
  echo "2.0" > debian-binary

  # Move control.tar.zst from DEBIAN/ to pkgdir.
  mv ./DEBIAN/control.tar.zst ./control.tar.zst

  # Create the .deb package, and remove extra files we created.
  ar -rU "${pkgname}_${pkgver}_${MAKEDEB_CARCH}.deb" debian-binary control.tar.zst data.tar.zst &> /dev/null
  rm debian-binary control.tar.zst data.tar.zst
}
