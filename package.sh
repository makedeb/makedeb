#!/usr/bin/env bash
#DESTDIR="{{ env_var('DESTDIR') }}"

set -eo pipefail
install -Dm 644 completions/makedeb.bash "${DESTDIR}/usr/share/bash-completion/completions/makedeb"
install -Dm 755 target/release/makedeb-rs "${DESTDIR}/usr/share/makedeb/makedeb-rs"

(
        cd src/
        install -Dm 755 ./main.sh "${DESTDIR}/usr/bin/makedeb"
        install -Dm 644 ./makepkg.conf "${DESTDIR}/etc/makepkg.conf"

        (
            cd functions/
            find ./ -type f -exec install -Dm 755 '{}' "${DESTDIR}/usr/share/makedeb/{}" \;
        )

        (
            cd extensions/
            find ./ -type f -exec install -Dm 644 '{}' "${DESTDIR}/usr/lib/makedeb/{}" \;
        )
)

asciidoctor -b manpage man/makedeb.8.adoc -o "${DESTDIR}/usr/share/man/man8/makedeb.8"
asciidoctor -b manpage man/makedeb-extension.5.adoc -o "${DESTDIR}/usr/share/man/man5/makedeb-extension.5"
asciidoctor -b manpage man/pkgbuild.5.adoc -o "${DESTDIR}/usr/share/man/man5/pkgbuild.5"
