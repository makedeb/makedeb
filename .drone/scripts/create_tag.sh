#!/usr/bin/env bash
set -ex
sudo chown 'makedeb:makedeb' ../ -R

TARGET=apt RELEASE="${DRONE_COMMIT_BRANCH}" BUMP_PKGREL=1 PKGBUILD/pkgbuild.sh > MAKEDEB.PKGBUILD

branch="${DRONE_COMMIT_BRANCH}"
pkgver="$(source MAKEDEB.PKGBUILD; echo "${pkgver}")"
pkgrel="$(source MAKEDEB.PKGBUILD; echo "${pkgrel}")"

echo "${github_api_key}" | gh auth login --with-token

# Generate release notes and create release.
release_notes=$'## Changes\n'
gh_cli_args=()

if [[ "${branch}" == 'stable' ]]; then
    release_notes+="$(parse-changelog CHANGELOG.md "${pkgver}")"
else
    case "${branch}" in
        'beta') article='a' ;;
        'alpha') article='an' ;;
    esac

    release_notes+="> The following contains the list of changes since the last **stable** release. This is ${article} **${branch}** release, and future changes will be appended to the below list until a new stable release is made."
    release_notes+=$'\n\n'
    release_notes+="$(parse-changelog CHANGELOG.md 'Unreleased')"
    gh_cli_args+=('--prerelease')
fi

release_notes+=$'\n\n## Supporters\nThank you to the following people for helping to make this release possible:\n'
release_notes+="$(cat patreon-sponsors.txt | sed 's|.*|- &|')"

# If the release is stable, make a new production release. Otherwise, make a prerelease.
gh release create "v${pkgver}-${pkgrel}" --title "v${pkgver}-${pkgrel}" --target "${DRONE_COMMIT_SHA}" -n "${release_notes}" "${gh_cli_args[@]}"

# vim: set sw=4 expandtab:
