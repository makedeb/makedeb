_makedeb() {
    shortopts=(
        '-A'
        '-d'
        '-F'
        '-p'
        '-g'
        '-h'
        '-H'
        '-i'
        '-V'
        '-r'
        '-s'
    )

    longopts=(
	'--allow-downgrades'
        '--as-deps'
        '--field'
        '--file'
        '--gen-integ'
        '--help'
        '--ignore-arch'
        '--install'
        '--lint'
	'--no-color'
        '--no-confirm'
        '--no-deps'
	'--pass-env'
        '--print-control'
        '--print-srcinfo'
        '--print-pgp-check'
        '--rm-deps'
        '--sync-deps'
        '--version'
    )

    local cur prev words cword
    _init_completion || return
    
    # We only want to show long options when '--' is provided.
    if [[ "${cur:0:2}" == "--" ]]; then
        mapfile -t COMPREPLY < <(compgen -W '${longopts[@]}' -- "${cur}")
    else
        mapfile -t COMPREPLY < <(compgen -W '${shortopts[@]}' -- "${cur}")
    fi
}

complete -F _makedeb makedeb

# vim: set sw=4 expandtab
