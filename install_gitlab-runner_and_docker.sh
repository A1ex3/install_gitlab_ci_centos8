#! /bin/bash

if ! command -v docker &> /dev/null; then
    yum install -y yum-utils
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum install docker-ce docker-ce-cli containerd.io -y

    systemctl start docker
    systemctl enable docker

    if ! command -v docker &> /dev/null; then
        echo "Failed to install Docker"
        exit 1
    else
        docker --version
    fi
fi

if ! command -v gitlab-runner &> /dev/null; then
    curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh" | sudo bash
    yum install gitlab-runner -y

    if ! command -v gitlab-runner &> /dev/null; then
        echo "Failed to install gitlab-runner"
        exit 1
    else
        gitlab-runner --version
    fi
fi

echo "Installation completed successfully!"