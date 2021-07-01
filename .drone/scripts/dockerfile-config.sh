#!/usr/bin/env bash

if [[ "${release_type}" == "beta" ]]; then
    sed -i 's|package=.*|package="makedeb-beta"|' docker/Dockerfile
elif [[ "${release_type}" == "alpha" ]]; then
    sed -i 's|package=.*|package="makedeb-alpha"|' docker/Dockerfile
fi
