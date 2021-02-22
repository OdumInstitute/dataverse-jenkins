#!/usr/bin/env bash
export LANG=en_US.UTF-8

IQSS_BRANCH=develop
IQSS_REPO=https://github.com/IQSS/dataverse.git 

usage() {
  echo "Usage: $0 -b <PR_branch> -r <PR_repo>"
  echo "The default repo and branch are IQSS/dataverse and develop, respectively."
  echo "Command-line arguments will specify a branch/repo to be merged with the IQSS develop branch."
  exit 0
}

while getopts ":r:b" o; do
  case "{o}" in
  r)
    PR_REPO=${OPTARG}
    ;;
  b)
    PR_BRANCH=${OPTARG}
    ;;
  *)
    usage
    ;;
  esac
done

# clone IQSS/dataverse:develop
git clone -b $IQSS_BRANCH $IQSS_REPO

# if we have PR vars, merge with develop
if [ ! -z $PR_BRANCH ];
   then cd /dataverse && git remote add pull $PR_REPO && git merge pull/$PR_BRANCH;
fi

# build warfile
echo "executing mvn -Djacoco.skip.instrument=false -DcompilerArgument=-Xlint:unchecked test -P all-unit-tests -T 2C package..."
echo "find stdout and stderr in /dataverse/mvn.out"
cd /dataverse && source /etc/profile.d/maven.sh && \
   mvn -Djacoco.skip.instrument=false -DcompilerArgument=-Xlint:unchecked test -P all-unit-tests -T 2C package > /dataverse/mvn.out 2>&1
echo ""
echo "generating surefire reports"
cd /dataverse && source /etc/profile.d/maven.sh && \
   mvn surefire-report:report > /dataverse/surefire.out 2>&1

echo "jacoco instrumentation"
mkdir /jacoco-tmp
cp /dataverse/target/dataverse-*.war /jacoco-tmp/dataverse.war
cd /jacoco-tmp && jar xf dataverse.war && rm dataverse.war
mv /jacoco-tmp/WEB-INF/classes /jacoco-tmp/WEB-INF/classes-orig
cd /jacoco-tmp && java -jar /jacoco/lib/jacococli.jar instrument WEB-INF/classes-orig/ --dest WEB-INF/classes
cd /jacoco-tmp && jar cf /jacoco-tmp/dataverse.war *
echo ""

echo "building dvinstall.zip"
cd /dataverse/scripts/installer && make clean && make dvinstall.zip
unzip /dataverse/scripts/installer/dvinstall.zip -d /
# allow unprivileged installer to write to /dvinstall
/bin/chmod o+w /dvinstall
echo "copying instrumented warfile into /dvinstall"
cp /jacoco-tmp/dataverse.war /dvinstall/dataverse.war

# start postgres
echo ""
echo "starting postgres"
sudo -u postgres /usr/pgsql-10/bin/pg_ctl start -D /var/lib/pgsql/data &
/bin/sleep 1
echo ""

# start solr
# current incompatibility in centos7 with sudo and raised values in /etc/security/limits.conf
# just run solr as root for now instead. sigh.
#sudo -u solr /usr/local/solr/bin/solr start
cp /dataverse/conf/solr/7.7.2/*.xml /usr/local/solr/server/solr/collection1/conf/
echo "starting solr"
/usr/local/solr/bin/solr start -force

# start payara
echo "launching payara..."
sudo -u payara /usr/local/payara5/bin/asadmin start-domain
echo ""

# deploy
echo "deploying dataverse. stdout and stderr in /dvinstall/install.out."
cd /dvinstall && sudo -u payara python3 install.py -f --config_file=default.config --noninteractive > install.out 2>&1
curl -X PUT -d FAKE http://localhost:8080/api/admin/settings/:DoiProvider

# restart payara
echo "restarting payara..."
sudo -u payara /usr/local/payara5/bin/asadmin stop-domain
sudo -u payara /usr/local/payara5/bin/asadmin start-domain

#echo "done, exiting."
#sudo -u payara /usr/local/payara5/bin/asadmin stop-domain
sleep infinity
