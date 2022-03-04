add_packaging_files() {
	# Maintainer scripts.
	# Print a warning if .install scripts are being used, as we've deprecated them.
	if [[ -f ".INSTALL" ]]; then
		warning2 "Installation scripts have been deprecated, and will no longer work. See the PKGBUILD(5) man page for information on using the new implementation."
	fi

	for i in 'preinst' 'postinst' 'prerm' 'postrm'; do
		filename=".${i^^}"
		
		if [[ -f "${filename}" ]]; then
			msg2 "Adding ${i} file..."
			cp "${filename}" "${pkgdir}/${package}/DEBIAN/${i}"
			chmod 755 "${pkgdir}/${package}/DEBIAN/${i}"
			
			if ! rm "${filename}"; then
				error "Failed to remove ${filename} from \$pkgdir."
			fi
		fi
	done

	# conffiles.
	if [[ "${backup[@]+x}" == "x" ]]; then
		touch "${pkgdir}/${package}/DEBIAN/conffiles"

		for i in "${backup[@]}"; do
			echo "${i}" >> "${pkgdir}/${package}/DEBIAN/conffiles"
		done
	fi
}
