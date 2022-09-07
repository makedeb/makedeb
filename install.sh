#!/usr/bin/env bash
set -e

# Handy env vars.
makedeb_url='makedeb.org'
color_normal="$(tput sgr0)"
color_bold="$(tput bold)"
color_green="$(tput setaf 77)"
color_orange="$(tput setaf 214)"
color_blue="$(tput setaf 14)"
color_red="$(tput setaf 202)"
color_purple="$(tput setaf 135)"

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

if [[ "${DEBIAN_FRONTEND}" == 'noninteractive' || "${NONINTERACTIVE:+x}" != '' || "${CI:+x}" != '' ]]; then
    noninteractive_mode=1
    export DEBIAN_FRONTEND=noninteractive
    apt_args=('-y')
    msg "Enabled noninteractive mode."
fi

msg "Ensuring needed packages are installed..."
if ! sudo apt-get update "${apt_args[@]}"; then
    die_cmd "Failed to update APT cache."
fi

if ! sudo apt-get install "${apt_args[@]}" -- gpg wget; then
    die_cmd "Failed to check if needed packages are installed."
fi

echo
msg "Multiple releases of makedeb are available for installation."
msg "Currently, you can install one of 'makedeb', 'makedeb-beta', or"
msg "'makedeb-alpha' by passing the \$MAKEDEB_RELEASE environment variable."

if [[ ! $noninteractive_mode && "${MAKEDEB_RELEASE:+x}" == '' ]]; then
    msg "No release was passed, applying default."
    MAKEDEB_RELEASE=makedeb
fi

case "$MAKEDEB_RELEASE" in
    makedeb|makedeb-alpha|makedeb-beta)
        ;;
    *)
        echo
        error "Invalid \$MAKEDEB_RELEASE: '${MAKEDEB_RELEASE}'"
        exit 1 ;;
esac

echo
msg "Proceeding to install '${MAKEDEB_RELEASE}' package..."

msg "Setting up makedeb APT repository..."
if ! wget -qO - "https://proget.${makedeb_url}/debian-feeds/makedeb.pub" | gpg --dearmor | sudo tee /usr/share/keyrings/makedeb-archive-keyring.gpg 1> /dev/null; then
    die_cmd "Failed to set up makedeb APT repository."
fi
echo "deb [signed-by=/usr/share/keyrings/makedeb-archive-keyring.gpg arch=all] https://proget.${makedeb_url} makedeb main" | sudo tee /etc/apt/sources.list.d/makedeb.list 1> /dev/null

msg "Updating APT cache..."
if ! sudo apt-get update "${apt_args[@]}"; then
    die_cmd "Failed to update APT cache."
fi

msg "Installing '${MAKEDEB_RELEASE}'..."
if ! sudo apt-get install "${apt_args[@]}" -- "${MAKEDEB_RELEASE}"; then
    die_cmd "Failed to install package."
fi

msg "Finished! If you need help of any kind, feel free to reach out:"
echo
msg "${color_bold}makedeb Homepage:${color_normal}            https://${makedeb_url}"
msg "${color_bold}makedeb Package Repository:${color_normal}  https://mpr.${makedeb_url}"
msg "${color_bold}makedeb Documentation:${color_normal}       https://docs.${makedeb_url}"
msg "${color_bold}makedeb Support:${color_normal}             https://docs.${makedeb_url}/support/obtaining-support"
echo
msg "Enjoy makedeb!"

# vim: set sw=4 expandtab:
