#!/usr/bin/env just --justfile
set positional-arguments
set export

default:
    @just --list

prepare:
    #!/usr/bin/env bash
    set -eo pipefail
    VERSION="{{ env_var('VERSION') }}"
    RELEASE="{{ env_var('RELEASE') }}"
    TARGET="{{ env_var('TARGET') }}"
    FILESYSTEM_PREFIX="{{ env_var_or_default('FILESYSTEM_PREFIX', '') }}"
    BUILD_COMMIT="{{ env_var('BUILD_COMMIT') }}"

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

build:
    #!/usr/bin/env bash
    set -eo pipefail
    DPKG_ARCHITECTURE="{{ env_var('DPKG_ARCHITECTURE') }}"

    case "${DPKG_ARCHITECTURE}" in
        amd64) target='x86_64-unknown-linux-gnu' ;;
        i386)  target='i686-unknown-linux-gnu' ;;
        arm64) target='aarch64-unknown-linux-gnu' ;;
        armhf) target='armv7-unknown-linux-gnueabihf' ;;
        *)     echo "Error: invalid architecture '${DPKG_ARCHITECTURE}'."; exit 1 ;;
    esac

    extra_cargo_args=()

    if [[ "${RUST_APT_WORKER_SIZES:+x}" == 'x' ]]; then
        extra_cargo_args+=('--features' 'rust-apt/worker_sizes')
    fi

    cargo build --target "${target}" --release "${extra_cargo_args[@]}"
    install -Dm 755 "target/${target}/release/makedeb-rs" target/release/makedeb-rs

package:
    #!/usr/bin/env bash
    DESTDIR="{{ env_var('DESTDIR') }}"

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

gen-po:
    find -iname '*.sh' -exec xgettext --add-comments --sort-output --package-name='makedeb' -o po/makedeb.pot '{}' +
