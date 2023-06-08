#!/usr/bin/env bash
shopt -s globstar
shopt -s dotglob
chmod 644 .gitignore
for i in ./**; do
    if [[ -d "$i" ]]; then
        chmod 755 "$i";
    else
        chmod 644 "$i";
    fi;
done

for i in ./.drone/scripts/**; do
    if [ -d "$i" ]; then
        chmod 755 "$i";
    else
        chmod 755 "$i";
    fi;
done

chmod 755 ./.githooks/pre-commit
chmod 755 ./src/main.sh
