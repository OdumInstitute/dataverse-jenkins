#!/bin/sh
PLAYBOOK=/root/jenkins.yml
curl -L https://github.com/IQSS/dataverse-jenkins/files/3258484/jenkins.yml.txt > /root/jenkins.yml
yum install -y ansible git vim-enhanced mlocate wget
ansible-galaxy install -p roles geerlingguy.jenkins
ansible-playbook $PLAYBOOK
