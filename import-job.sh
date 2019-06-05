#!/bin/sh
SERVER=http://ec2-35-153-131-168.compute-1.amazonaws.com:8080
USERNAME=admin
PASSWORD=admin
java -jar /opt/jenkins-cli.jar -s $SERVER -auth $USERNAME:$PASSWORD create-job IQSS-dataverse-develop < /root/dataverse-jenkins/config.xml
