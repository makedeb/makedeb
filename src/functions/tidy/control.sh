write_control_pair() {
    local target_var="${1}"
    local values=()

    for value in "${@:2}"; do
        values+=("${value},")
    done

    if [[ "${#values[@]}" == 0 ]] || [[ "${#values[@]}" == 1 && "${values}" == "," ]]; then
        return
    fi

    echo "${target_var}: ${values[@]}" | sed 's|,$||'
}

# vim: set sw=4 expandtab:
