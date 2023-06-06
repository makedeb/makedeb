#!/usr/bin/env bash
shopt -s globstar
chmod 644 .gitignore
for i in ./**; do
    if [ -d "$i" ]; then
        chmod 755 "$i";
    else
        chmod 644 "$i";
    fi;
done
