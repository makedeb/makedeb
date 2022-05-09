#!/usr/bin/env bash
set -e

# Handy env vars.
hw_url='hunterwittenborn.com'
color_normal="$(tput sgr0)"
color_green="$(tput setaf 77)"
color_orange="$(tput setaf 214)"
color_blue="$(tput setaf 14)"
color_red="$(tput setaf 202)"
color_purple="$(tput setaf 135)"

# Answer vars.
SETUP_PREBUILT_MPR=0
MAKEDEB_PKG='makedeb'

# Handy functions.
msg() {
    echo "${color_blue}[>]${color_normal} ${1}"
}

error() {
    echo "${color_red}[!]${color_normal} ${1}"
}

question() {
    echo "${color_purple}[?]${color_normal} ${1}"
}

die_cmd() {
    error "${1}"
    exit 1
}

answered_yes() {
    if [[ "${1}" == "" || "${1,,}" == "y" ]]; then
        return 0
    else
        return 1
    fi
}

# Pre-checks.
if [[ "${UID}" == "0" ]]; then
    die_cmd "This script is not allowed to be run under the root user. Please run as a normal user and try again."
fi

# Program start.
echo "-------------------------"
echo "${color_green}[#]${color_normal} ${color_orange}makedeb Installer${color_normal} ${color_green}[#]${color_normal}"
echo "-------------------------"

echo
msg "Ensuring needed packages are installed..."
if ! sudo apt-get update; then
    die_cmd "Failed to update APT cache."
fi

if ! sudo apt-get satisfy gpg lsb-release; then
    die_cmd "Failed to check if needed packages are installed."
fi

echo
msg "Multiple releases of makedeb are available for installation."
msg "Currently, you can install one of 'makedeb', 'makedeb-beta', or"
msg "'makedeb-alpha'."
msg "If you're not sure which one to choose, pick 'makedeb'."

while true; do
    read -p "$(question "Which release would you like? ")" response

    if [[ "${response}" != 'makedeb' && "${response}" != 'makedeb-beta' && "${response}" != 'makedeb-alpha' ]]; then
        error "Invalid response: ${response}"
        continue
    fi

    break
done

MAKEDEB_PKG="${response}"

echo
msg "The makedeb Package Repository (MPR) contains access to a wide variety of"
msg "packages for use with makedeb."
msg "The Prebuilt-MPR offers a platform for prebuilt packages from the MPR, and"
msg "can aid in installing packages from the MPR in a quicker manner than"
msg "building from source."
read -p "$(question "Would you like to set up the Prebuilt-MPR APT repository in addition to the"; question "standard makedeb APT repository? [Y/n] ")" response

if answered_yes "${response}"; then
    SETUP_PREBUILT_MPR=1
fi

msg "Setting up makedeb APT repository..."
if ! curl -s "https://proget.${hw_url}/debian-feeds/makedeb.pub" | gpg --dearmor | sudo tee /usr/share/keyrings/makedeb-archive-keyring.gpg 1> /dev/null; then
    die_cmd "Failed to set up makedeb APT repository."
fi
echo "deb [signed-by=/usr/share/keyrings/makedeb-archive-keyring.gpg arch=all] https://proget.${hw_url} makedeb main" | sudo tee /etc/apt/sources.list.d/makedeb.list 1> /dev/null

if (( "${SETUP_PREBUILT_MPR}" )); then
    msg "Setting up Prebuilt-MPR APT repository..."
    
    if ! curl -s "https://proget.${hw_url}/debian-feeds/prebuilt-mpr.pub" | gpg --dearmor | sudo tee /usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg 1> /dev/null; then
        die_cmd "Failed to set up Prebuilt-MPR APT repository."
    fi
    echo "deb [signed-by=/usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg] https://proget.${hw_url} prebuilt-mpr $(lsb_release -cs)" | sudo tee /etc/apt/sources.list.d/prebuilt-mpr.list 1> /dev/null
fi

msg "Updating APT cache..."
if ! sudo apt-get update; then
    die_cmd "Failed to update APT cache."
fi

msg "Installing '${MAKEDEB_PKG}'..."
if ! sudo apt-get install -- "${MAKEDEB_PKG}"; then
    die_cmd "Failed to install package."
fi

msg "Finished. Enjoy makedeb!"

# vim: set sw=4 expandtab:
