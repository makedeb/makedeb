remove_dependency_description() {
    # This removes comments from optdepends(i.e. 'google-chrome: for shill users')
    # These comments are placed as I almost deleted this a bit ago thinking
    # it didn't have a purpose.
    NUM=0
    while [[ "${optdepends[$NUM]}" != "" ]]; do
        local temp_new_optdepends+=" $(echo ${optdepends[$NUM]} | cut -d':' -f 1)"
        NUM=$(( ${NUM} + 1 ))
    done
    new_optdepends=$(echo ${temp_new_optdepends[@]} | xargs)
}
