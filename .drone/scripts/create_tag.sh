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

# If the release is stable, get release notes and make a new production release. Otherwise, add no release notes and make a prerelease.
branch="${DRONE_COMMIT_BRANCH}"
pkgver="$(cat .data.json | jq -r '.current_pkgver')"
pkgrel="$(cat .data.json | jq -r ".current_pkgrel_${branch}")"

echo "${github_api_key}" | gh auth login --with-token

if [[ "${DRONE_COMMIT_BRANCH}" == 'stable' ]]; then
    release_notes="$(parse-changelog CHANGELOG.md "${pkgver}")"
    gh release create "v${pkgver}-${pkgrel}" --title "v${pkgver}-${pkgrel}" --target "${DRONE_COMMIT_SHA}" -n "${release_notes}"
else
    gh release create "v${pkgver}-${pkgrel}" --title "v${pkgver}-${pkgrel}" --target "${DRONE_COMMIT_SHA}" -n "This is a **prerelease**\! Things may be broken, and you should avoid this release if you're expecting stability." --prerelease
fi

# vim: set sw=4 expandtab:
