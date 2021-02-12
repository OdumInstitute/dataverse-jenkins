#!/usr/bin/env bash
export LANG=en_US.UTF-8

# start postgres
sudo -u postgres /usr/pgsql-9.6/bin/pg_ctl start -D /var/lib/pgsql/data &

# start solr
# current incompatibility in centos7 with sudo and raised values in /etc/security/limits.conf
# just run solr as root for now instead. sigh.
#sudo -u solr /usr/local/solr/bin/solr start
/usr/local/solr/bin/solr start -force

# start payara
sudo -u payara /usr/local/payara5/bin/asadmin start-domain
sleep infinity

