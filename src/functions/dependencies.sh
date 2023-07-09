#!/bin/bash
for lib in "${LIBRARY:-'/usr/share/makepkg'}/dependencies/"*.sh; do
	source "$lib"
done
