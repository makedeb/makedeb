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
        '--ignore-arch'
        '--no-deps'
        '--file'
        '--gen-integ'
        '--help'
        '--field'
        '--install'
        '--version'
        '--rm-deps'
        '--sync-deps'
        '--lint'
        '--print-control'
        '--print-srcinfo'
        '--print-pgp-check'
        '--as-deps'
        '--no-confirm'
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
