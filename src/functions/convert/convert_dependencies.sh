convert_deps() {
    if [[ "${depends}" == "" ]] && \
        [[ "${optdepends}" == "" ]] && \
        [[ "${conflicts}" == "" ]] && \
        [[ "${provides}" == "" ]] && \
        [[ "${replaces}" == "" ]] && \
        [[ "${makedepends}" == "" ]] && \
        [[ "${checkdepends}" == "" ]]; then
        true
    else

        if [[ "${in_fakeroot}" != "true" ]]; then
            msg "Attempting to convert dependencies..."
        else
            true
        fi

        new_depends=${depends[@]}
        new_optdepends=${new_optdepends[@]}
        new_conflicts=${conflicts[@]}
        new_provides=${provides[@]}
        new_makedepends=${makedepends[@]}
        new_checkdepends=${checkdepends[@]}

        # Pipe explanation:
        # 1. Run 'makedeb-db' with dependencies specified in PKGBUILD
        # 2. Run 'jq' to format with newlines
        # 3. Remove '{', '}', '"', and ',' from the output
        # 4. Replace ': ' with '='
        # 5. Run 'xargs' to format with single spacing
        for pkg in $(makedeb-db --general ${new_depends} ${new_optdepends} ${new_conflicts} ${new_makedepends} ${new_checkdepends} | jq | sed 's|[{}",]||g' | sed 's|: |=|g' | xargs); do
            string1=$(echo "${pkg}" | awk -F= '{print $1}')
            string2="$(echo "${pkg}" | awk -F= '{print $2}')"

            new_depends=$(echo ${new_depends[@]} | sed "s/${string1}/${string2}/g")
            new_optdepends=$(echo ${new_optdepends[@]} | sed "s/${string1}/${string2}/g")
            new_conflicts=$(echo ${new_conflicts[@]} | sed "s/${string1}/${string2}/g")
            new_provides=$(echo ${new_provides[@]} | sed "s/${string1}/${string2}/g")
            new_makedepends=$(echo ${new_makedepends[@]} | sed "s/${string1}/${string2}/g")
            new_checkdepends=$(echo ${new_checkdepends[@]} | sed "s/${string1}/${string2}/g")
        done
    fi
}
