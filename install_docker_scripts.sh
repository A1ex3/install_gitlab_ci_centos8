#! /bin/bash

PWD=$(pwd)
REPO_NAME="install_gitlab_ci_centos8"
REPO_VERSION="v0.0.3"
WORK_DIR_NAME="/gitlab_ci_scripts"

function check_dependency () {
    if ! command -v $1 &> /dev/null; then
        echo "'$1' not found!"
        return 1
    else
        return 0
    fi
}

check_dependency git || exit 1
check_dependency python3 || exit 1
check_dependency pip && pip3 || exit 1

rm -rf $REPO_NAME
if ! git clone -b "$REPO_VERSION" https://github.com/A1ex3/"$REPO_NAME.git"; then
    echo "Failed to clone the repository!"
    exit 1
fi

if cp "$REPO_NAME/dckr/gitlab_ci_docker_scripts.service" /etc/systemd/system/gitlab_ci_docker_scripts.service; then
    rm -f "$REPO_NAME/dckr/gitlab_ci_docker_scripts.service"
else
    echo "Failed to copy service file!"
    exit 1
fi

rm -rf "$WORK_DIR_NAME"
mkdir -p "$WORK_DIR_NAME"
cp -ru "$REPO_NAME/dckr/"* "$WORK_DIR_NAME"
rm -rf "$REPO_NAME"

cd "$WORK_DIR_NAME" || exit 1

if ! python3 -m venv venv; then
    echo "Failed to create venv!"
    exit 1
fi

if ! ./venv/bin/pip3 install -r requirements.txt; then
    echo "Failed to install dependencies for Python!"
    exit 1
fi

cd "$PWD" || exit 1