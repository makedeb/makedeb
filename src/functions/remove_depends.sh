remove_depends() {
  if [[ $(eval echo \${${1}_packages}) != "" ]]; then
    echo "Removing unneeded ${1} dependencies..."
    sudo dpkg -r $(eval echo \${${1}_packages}) &> /dev/null
  fi
}
