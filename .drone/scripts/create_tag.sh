#!/usr/bin/env bash
set -ex

# Install prerequisites.
apt update
apt install curl jq lsb-release gpg -y

# Set up the Prebuilt-MPR.
curl -q "https://proget.${makedeb_url}/debian-feeds/prebuilt-mpr.pub" | gpg --dearmor | tee /usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg 1> /dev/null
echo "deb [signed-by=/usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg] https://proget.${makedeb_url} prebuilt-mpr $(lsb_release -cs)" | tee /etc/apt/sources.list.d/prebuilt-mpr.list

# Install needed packages from PBMPR.
apt update
apt-get install gh parse-changelog -y

branch="${DRONE_COMMIT_BRANCH}"
pkgver="$(cat .data.json | jq -r '.current_pkgver')"
pkgrel="$(cat .data.json | jq -r ".current_pkgrel_${branch}")"

echo "${github_api_key}" | gh auth login --with-token

# Generate release notes and create release.
release_notes=$'## Changes\n'
gh_cli_args=()

if [[ "${branch}" == 'stable' ]]; then
    release_notes+="$(parse-changelog CHANGELOG.md "${pkgver}")"
else
    release_notes+=$'> The following contains the list of changes since the last stable release.\n\n'
    release_notes+="$(parse-changelog CHANGELOG.md 'Unreleased')"
    gh_cli_args+=('--prerelease')
fi

release_notes+=$'\n\n## Supporters\nThank you to the following people for helping to make this release possible:\n'
release_notes+="$(cat patreon-sponsors.txt | sed 's|.*|- &|')"

# If the release is stable, make a new production release. Otherwise, make a prerelease.
gh release create "v${pkgver}-${pkgrel}" --title "v${pkgver}-${pkgrel}" --target "${DRONE_COMMIT_SHA}" -n "${release_notes}" "${gh_cli_args[@]}"

# vim: set sw=4 expandtab:
