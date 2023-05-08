#!/usr/bin/env bash
find -iname '*.sh' -exec xgettext --add-comments --sort-output --package-name='makedeb' -o po/makedeb.pot '{}' +
