root_check() {
  if [[ "$(whoami)" == "root" ]]; then
    echo "Running makedeb as root is not allowed as it can cause irreversable damage to your system."
    exit 1
  fi
}
