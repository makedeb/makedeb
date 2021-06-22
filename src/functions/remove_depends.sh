remove_depends() {
  if [[ $(eval echo \${apt_${1}depends}) != "" ]]; then
    msg "Removing ${1} dependencies..."
    eval sudo apt remove \${apt_${1}depends} -y
  fi
}
