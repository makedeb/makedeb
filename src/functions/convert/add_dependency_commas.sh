add_dependency_commas() {
	eval declare -g depends=("$(echo ${depends[@]@Q} | sed 's| |, |g')")
	eval declare -g recommends=("$(echo ${recommends[@]@Q} | sed 's| |, |g')")
	eval declare -g suggests=("$(echo ${suggests[@]@Q} | sed 's| |, |g')")
	eval declare -g conflicts=("$(echo ${conflicts[@]@Q} | sed 's| |, |g')")
	eval declare -g provides=("$(echo ${provides[@]@Q} | sed 's| |, |g')")
	eval declare -g replaces=("$(echo ${replaces[@]@Q} | sed 's| |, |g')")
	eval declare -g license=("$(echo ${license[@]@Q} | sed 's| |, |g')")
}
