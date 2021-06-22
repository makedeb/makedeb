trap_codes() {
  trap_int() {
    # We're gonna put cleanup functions here later for make dependencies (and maybe other stuff)
    error "Aborted by user. Exiting..."
    exit 1
  }

  trap trap_int sigint
}
