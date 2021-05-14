#!/usr/bin/env bash
set -e

echo "+ Installing git"
apt update
apt install git -y

echo "+ Cloning repository"
git clone "${DRONE_GIT_HTTP_URL}"
