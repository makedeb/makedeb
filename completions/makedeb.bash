_makedeb() {
    short_opts=('-A' '-d' '-F' '-g'
                '-h' '-H' '-V' '-r'
                '-s')

    long_opts=('--ignore-arch' '--no-deps' '--file' '--gen-integ'
               '--help' '--field' '--version' '--rm-deps' '--sync-deps'
               '--print-control' '--print-srcinfo' '--skip-pgp-check' '--verbose'
               '--no-confirm')
    
    installation_source="$(makedeb --version | sed -n 3p | awk '{print $3}')"

    if [[ "${installation_source}" != "AUR" ]]; then
        short_opts+=('-i')
        long_opts+=('--install' '--as-deps')
    fi

	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	case "${prev}" in
		-F|--file) mapfile -t COMPREPLY < <(find ./ -maxdepth 1 -type f -not -path './' | sed 's|^\./||' | grep "^${cur}" 2> /dev/null); return ;;
        -H|--field) return ;;
	esac
    
    mapfile -t COMPREPLY < <(printf '%s\n' "${short_opts[@]}"  "${long_opts[@]}" | grep "^${cur}" 2> /dev/null)
}

complete -o filenames -o bashdefault -F _makedeb makedeb
