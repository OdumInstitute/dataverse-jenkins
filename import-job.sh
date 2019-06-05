#!/bin/sh
SERVER=http://localhost:8080
USERNAME=admin
PASSWORD=admin
java -jar /opt/jenkins-cli.jar -s $SERVER -auth $USERNAME:$PASSWORD create-job IQSS-dataverse-develop < config.xml
