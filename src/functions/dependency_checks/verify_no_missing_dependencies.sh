verify_no_missing_dependencies() {
  if [[ "${#missing_dependencies[@]}" != "0" || "${#missing_build_dependencies[@]}" != "0" ]]; then
    error "The following build dependencies are missing:"
    
    for i in "${missing_dependencies_no_relations[@]}" "${missing_build_dependencies_no_relations[@]}"; do
      msg2 "${i}"
    done
    
    exit 1
  fi
  
  echo "${missing_build_dependencies[@]}"
  exit
}
