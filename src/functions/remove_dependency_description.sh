remove_dependency_description() {
    # This removes comments from optdepends(i.e. 'google-chrome: for shill users')
    # These comments are placed as I almost deleted this a bit ago thinking
    # it didn't have a purpose.
	local temp_optdepends=()

    for i in "${optdepends[@]}"; do
        local temp_optdepends+=("$(echo "${i}" | awk -F ':' '{print $1}')")
    done

    eval optdepends=($(echo "${temp_optdepends[@]@Q}"))
}
