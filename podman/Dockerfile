FROM docker.io/library/centos:7

# repo and branch arguments. PR_* may be passed as Docker --build-args
ARG IQSS_REPO=https://github.com/IQSS/dataverse
ARG IQSS_BRANCH=develop
ARG PR_REPO
ARG PR_BRANCH

# component arguments. maybe we'll make these override-able.
ARG DEFAULT_CONFIG=https://raw.githubusercontent.com/IQSS/dataverse/develop/scripts/installer/default.config
ARG DVINSTALL_ZIP=https://github.com/IQSS/dataverse/releases/download/v5.3/dvinstall.zip
ARG JACOCO_ZIP=https://repo1.maven.org/maven2/org/jacoco/jacoco/0.8.6/jacoco-0.8.6.zip
ARG MAVEN_URL=https://www-us.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
ARG PAYARA_URL=https://s3-eu-west-1.amazonaws.com/payara.fish/Payara+Downloads/5.2020.6/payara-5.2020.6.zip
ARG SOLR_URL=https://archive.apache.org/dist/lucene/solr/7.7.2/solr-7.7.2.tgz

# OS dependencies
RUN yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
RUN yum -y update
RUN yum install -y epel-release bsdtar curl git ImageMagick java-11-openjdk-devel lsof postgresql96-server python-psycopg2 sudo unzip
# jq is only available in EPEL, hence the second call
RUN yum install -y jq

# clone IQSS/dataverse:develop
RUN git clone -b ${IQSS_BRANCH} ${IQSS_REPO}
# if we have PR vars, merge with develop
RUN if [ ! -z ${PR_BRANCH} ]; then cd /dataverse && git remote add pull ${PR_REPO} && git merge pull/${PR_BRANCH}; fi

# grab dvinstall.zip - just use release for now. maybe invoke Makefile?
RUN curl -L -O ${DVINSTALL_ZIP} && unzip -q dvinstall.zip && \
    curl -L -o /dvinstall/default.config ${DEFAULT_CONFIG}

# initialize postgres
RUN sudo -u postgres /usr/pgsql-9.6/bin/initdb /var/lib/pgsql/data

# install solr
RUN curl -O ${SOLR_URL}
RUN mkdir /usr/local/solr && bsdtar --strip-components=1 -C /usr/local/solr -xf /solr-*
RUN echo "solr soft nproc 65000" >> /etc/security/limits.conf && \
    echo "solr hard nproc 65000" >> /etc/security/limits.conf && \
    echo "solr soft nofile 65000" >> /etc/security/limits.conf && \
    echo "solr hard nofile 65000" >> /etc/security/limits.conf
RUN mkdir -p /usr/local/solr/server/solr/collection1/conf && \
    echo "name=collection1" > /usr/local/solr/server/solr/collection1/core.properties && \
    sed -i 's/solr.jetty.request.header.size"\ default="8192"/solr.jetty.request.header.size"\ default="102400"/' /usr/local/solr/server/etc/jetty.xml
RUN useradd solr && chown -R solr:solr /usr/local/solr

# install payara
RUN curl -O ${PAYARA_URL}
RUN mkdir /usr/local/payara5 && bsdtar --strip-components=1 -C /usr/local/payara5 -xf /payara-*
RUN useradd payara && chown -R payara:payara /usr/local/payara5

# download jacoco
RUN curl -L -O ${JACOCO_ZIP} && unzip -q jacoco-*.zip -d /jacoco
RUN cp /jacoco/lib/jacocoagent.jar /usr/local/payara5/glassfish/lib/

# install maven
RUN curl -L -O ${MAVEN_URL}
RUN mkdir /opt/maven && bsdtar --strip-components=1 -C /opt/maven -xf /apache-maven-3.*
RUN echo "export JAVA_HOME=/usr/lib/jvm/jre-openjdk" > /etc/profile.d/maven.sh && \
    echo "export M2_HOME=/opt/maven" >> /etc/profile.d/maven.sh && \
    echo "export MAVEN_HOME=/opt/maven" >> /etc/profile.d/maven.sh && \
    echo "export PATH=/opt/maven/bin:${PATH}" >> /etc/profile.d/maven.sh

# don't expose ports lest we collide with other containers, but in case you want to:
# payara
#EXPOSE 8080
#EXPOSE 4848
# solr
#EXPOSE 8983
# postgres
#EXPOSE 5432

# keeping the symlink on the off chance that something else is still assuming /usr/local/glassfish4
RUN ln -s /usr/local/payara5 /usr/local/glassfish4
COPY entrypoint.bash /
CMD ["/entrypoint.bash"]
