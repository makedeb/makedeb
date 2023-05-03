#!/usr/bin/env bash
set -eo pipefail
#VERSION="{{ env_var('VERSION') }}"
#RELEASE="{{ env_var('RELEASE') }}"
#TARGET="{{ env_var('TARGET') }}"
#FILESYSTEM_PREFIX="{{ env_var_or_default('FILESYSTEM_PREFIX', '') }}"
#BUILD_COMMIT="{{ env_var('BUILD_COMMIT') }}"
(
        cd src/
        sed -i \
            -e "s|{{'{{'}}MAKEDEB_VERSION}}|${VERSION}|" \
            -e "s|{{'{{'}}MAKEDEB_RELEASE}}|${RELEASE}|" \
            -e "s|{{'{{'}}MAKEDEB_INSTALLATION_SOURCE}}|${TARGET}|" \
            -e "s|{{'{{'}}FILESYSTEM_PREFIX}}|${FILESYSTEM_PREFIX}|" \
            -e "s|{{'{{'}}MAKEDEB_BUILD_COMMIT}}|${BUILD_COMMIT}|" \
            -e 's|^MAKEDEB_PACKAGED=0$|MAKEDEB_PACKAGED=1|' \
            main.sh
)

sed -i "s|\$\${pkgver}|${VERSION}|" man/*
