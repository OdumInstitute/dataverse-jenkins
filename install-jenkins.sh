#!/bin/sh
yum install -y ansible git maven zip unzip vim-enhanced mlocate wget
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io
systemctl start docker
systemctl enable docker
usermod -aG docker centos
usermod -aG docker jenkins
ansible-galaxy install -p roles geerlingguy.jenkins
ansible-playbook jenkins.yml
