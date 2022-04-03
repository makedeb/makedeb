#!/bin/bash
LIBRARY=${LIBRARY:-'/usr/share/makepkg'}

for lib in "$LIBRARY/dependencies/"*.sh; do
	source "$lib"
done
