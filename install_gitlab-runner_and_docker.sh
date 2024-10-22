#! /bin/bash

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
    curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh" | sudo bash
    sudo yum install gitlab-runner -y

    if ! command -v gitlab-runner &> /dev/null; then
        echo "Failed to install gitlab-runner"
        exit 1
    else
        gitlab-runner --version
    fi
fi

echo "Installation completed successfully!"