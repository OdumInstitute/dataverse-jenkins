Dataverse-Jenkins
=================

This repository aims to document the configuration of automated testing for [Dataverse][] and its satellite projects.

The [Odum Institute][] hosts [jenkins.dataverse.org][] as a vanilla CentOS 7 VM running [Jenkins][]' standard [repo RPM][]. If you would like to stand up your own Jenkins instance, we recommend GeerlingGuy's excellent [Jenkins Ansible role][].

In our current configuration, Jenkins waits for a webhook push from [IQSS/dataverse-develop][], builds the Dataverse warfile and in the near future will deploy it to a test VM. You may find this [config.xml][] file helpful to get you started. You may import it by using the [Jenkins-CLI jar][]:

	$ java -jar jenkins-cli.jar -s http://server create-job mydataversejob < config.xml

[Dataverse]: https://dataverse.org/
[Odum Institute]: https://odum.unc.edu
[jenkins.dataverse.org]: https://jenkins.dataverse.org/
[Jenkins]: https://jenkins.io/
[repo RPM]: https://pkg.jenkins.io/redhat/
[Jenkins Ansible Role]: https://github.com/geerlingguy/ansible-role-jenkins
[IQSS/dataverse-develop]: https://github.com/IQSS/dataverse/tree/develop
[config.xml]: config.xml
[Jenkins-CLI jar]: https://wiki.jenkins.io/display/JENKINS/Jenkins+CLI
