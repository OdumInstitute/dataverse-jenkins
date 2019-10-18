#!/bin/sh

if [ ! -z $1 ]; then
   JOB=$1
else
   JOB="IQSS-dataverse-develop"
fi

SERVER=http://localhost:8080
USERNAME=admin
PASSWORD=admin
java -jar /opt/jenkins-cli.jar -s $SERVER -auth $USERNAME:$PASSWORD create-job $JOB < $JOB.xml
