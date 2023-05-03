#!/usr/bin/env bash
set -eo pipefail
#DPKG_ARCHITECTURE="{{ env_var('DPKG_ARCHITECTURE') }}"

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
