# This is used to convert grouped short options (i.e. -asdf) to
# singular short options (i.e. -a -s -d -f)
split_args() {
    if echo "${1}" | grep '^-[[:alnum:]][[:alnum:]]' &> /dev/null; then

        for i in $(echo "${1}" | sed 's|-||' | sed 's|.|& |g'); do
            argument_list+=("-${i}")
        done
        
    else
        argument_list+=("${1}")
    fi
}
