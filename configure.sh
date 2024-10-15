#! /bin/bash

./centos-stream-8-vault-repos.sh

if ! command -v docker &> /dev/null; then
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install docker-ce docker-ce-cli containerd.io -y

    sudo systemctl start docker
    sudo systemctl enable docker

    if ! command -v docker &> /dev/null; then
        echo "Failed to install Docker"
        exit 1
    else
        docker --version
    fi
fi

if ! command -v gitlab-runner &> /dev/null; then
    curl -L --output /etc/yum.repos.d/gitlab-runner.repo https://packages.gitlab.com/runner/gitlab-runner/el/8/gitlab-runner.repo
    sudo yum install gitlab-runner -y

    if ! command -v gitlab-runner &> /dev/null; then
        echo "Failed to install gitlab-runner"
        exit 1
    else
        gitlab-runner --version
    fi
fi