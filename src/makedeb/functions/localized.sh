# We use this to force the output of programs to be in English to prevent any parsing issues.
localized() {
  LC_ALL=C "${@}"
}
