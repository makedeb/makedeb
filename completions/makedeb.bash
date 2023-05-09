_makedeb() {
shortopts=(
'-A'
'-c'
'-C'
'-d'
'-e'
'-f'
'-g'
'-h'
'-H'
'-i'
'-V'
'-r'
'-R'
'-s'
'-V'
'-m'
'-o'
'-p'
)

longopts=(
"--ignorearch"
"--clean"
"--cleanbuild" 
"--nodeps"
"--noextract" 
"--force" 
"--geninteg" 
"--help"
"--field"
"--install"
"--version"
"--rmdeps" 
"--repackage"
"--syncdeps" 
"--version"
"--config:"
"--lint"
"--nocolor" 
"--nobuild" 
"--file:"
"--nocheck" 
"--noarchive" 
"--noprepare" 
"--nosign" 
"--printcontrol" 
"--printsrcinfo" 
"--sign" 
"--skipchecksums" 
"--skippgpcheck" 
"--verifysource" 
"--asdeps" 
"--allowdowngrades" 
"--noconfirm" 
"--reinstall" 
"--in-fakeroot"
"--mprcheck" "durcheck"
"--passenv"
"--msg" 
"--msg2" 
"--warning" 
"--warning2" 
"--error" 
"--error2"
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

# vim: set sw=4 expandtab:
