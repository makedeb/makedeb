#!/usr/bin/env bash
# This only runs on the AUR release. See the build.sh script in /scripts if
# you'd like to know how it happends.
##
# This won't stop arg_check() from checking for the install option, but it
# won't do anything when invoked.

sed -i "s|\${INSTALL}||g" "${srcdir}"/makedeb/src/makedeb.sh
sed -i 's|echo "  -I.*||g' "${srcdir}"/makedeb/src/functions/help.sh
