#!/usr/bin/env bash

if [[ "${release_type}" == "alpha" ]]; then
    sed -i 's|package=.*|package="makedeb-alpha"|' docker/Dockerfile
fi
