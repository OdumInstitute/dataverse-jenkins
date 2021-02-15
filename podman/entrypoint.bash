#!/usr/bin/env bash
export LANG=en_US.UTF-8

# start postgres
echo ""
echo "starting postgres"
sudo -u postgres /usr/pgsql-9.6/bin/pg_ctl start -D /var/lib/pgsql/data &
echo ""

# start solr
# current incompatibility in centos7 with sudo and raised values in /etc/security/limits.conf
# just run solr as root for now instead. sigh.
#sudo -u solr /usr/local/solr/bin/solr start
echo "starting solr"
/usr/local/solr/bin/solr start -force

# start payara
echo "launching payara..."
sudo -u payara /usr/local/payara5/bin/asadmin start-domain
echo ""

# build warfile
echo "executing mvn -Djacoco.skip.instrument=false -DcompilerArgument=-Xlint:unchecked test -P all-unit-tests package..."
echo "find stdout and stderr in /dataverse/mvn.out"
cd /dataverse && source /etc/profile.d/maven.sh && \
   mvn -Djacoco.skip.instrument=false -DcompilerArgument=-Xlint:unchecked test -P all-unit-tests package > /dataverse/mvn.out 2>&1
echo ""
echo "generating surefire reports"
cd /dataverse && source /etc/profile.d/maven.sh && \
   mvn surefire-report:report > /dataverse/surefire.out 2>&1

# jacoco instrumentation
mkdir /jacoco-tmp
cp /dataverse/target/dataverse-*.war /jacoco-tmp/dataverse.war
cd /jacoco-tmp && jar xf dataverse.war
mv /jacoco-tmp/WEB-INF/classes /jacoco-tmp/WEB-INF/classes-orig
cd /jacoco-tmp && java -jar /jacoco/lib/jacococli.jar instrument WEB-INF/classes-orig/ --dest WEB-INF/classes
cd /jacoco-tmp && jar cf /jacoco-tmp/dataverse.war *
cp /jacoco-tmp/dataverse.war /dvinstall/dataverse.war
echo ""

# deploy
echo "deploying dataverse. stdout and stderr in /dvinstall/install.out."
cd /dvinstall && sudo -u payara python install.py -f --config_file=default.config --noninteractive > install.out 2>&1
curl -X PUT -d FAKE http://localhost:8080/api/admin/settings/:DoiProvider

# restart payara
echo "restarting payara..."
sudo -u payara /usr/local/payara5/bin/asadmin stop-domain
sudo -u payara /usr/local/payara5/bin/asadmin start-domain

#echo "done, exiting."
#sudo -u payara /usr/local/payara5/bin/asadmin stop-domain
sleep infinity
