#!/bin/sh
yum install -y ansible git maven vim-enhanced mlocate wget
ansible-galaxy install -p roles geerlingguy.jenkins
ansible-playbook jenkins.yml
