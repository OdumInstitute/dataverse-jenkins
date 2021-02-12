FROM docker.io/library/centos:7

# repo and branch arguments. PR_* may be passed as Docker --build-args
ARG IQSS_REPO=https://github.com/IQSS/dataverse
ARG IQSS_BRANCH=develop
ARG PR_REPO
ARG PR_BRANCH

ARG MAVEN_URL=https://www-us.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
ARG PAYARA_URL=https://s3-eu-west-1.amazonaws.com/payara.fish/Payara+Downloads/5.2020.6/payara-5.2020.6.zip
ARG SOLR_URL=https://archive.apache.org/dist/lucene/solr/7.7.2/solr-7.7.2.tgz

# OS dependencies
RUN yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
RUN yum install -y epel-release bsdtar curl git java-11-openjdk-devel lsof postgresql96-server sudo unzip
# jq is only available in EPEL, hence the second call
RUN yum install -y jq

# clone IQSS/dataverse:develop
RUN git clone -b ${IQSS_BRANCH} ${IQSS_REPO}
# if we have PR vars, merge with develop
RUN if [ ! -z ${PR_BRANCH} ]; then cd /dataverse && git remote add pull ${PR_REPO} && git merge pull/${PR_BRANCH}; fi

# initialize postgres
RUN sudo -u postgres /usr/pgsql-9.6/bin/initdb /var/lib/pgsql/data

# install solr
RUN curl -O ${SOLR_URL}
RUN mkdir /usr/local/solr && bsdtar --strip-components=1 -C /usr/local/solr -xf /solr-*
RUN echo "solr soft nproc 65000" >> /etc/security/limits.conf && \
    echo "solr hard nproc 65000" >> /etc/security/limits.conf && \
    echo "solr soft nofile 65000" >> /etc/security/limits.conf && \
    echo "solr hard nofile 65000" >> /etc/security/limits.conf
RUN mkdir -p /usr/local/solr/server/solr/collection1/conf && echo "name=collection1" > /usr/local/solr/server/solr/collection1/core.properties
RUN useradd solr && chown -R solr:solr /usr/local/solr

# install payara
RUN curl -O ${PAYARA_URL}
RUN mkdir /usr/local/payara5 && bsdtar --strip-components=1 -C /usr/local/payara5 -xf /payara-*
RUN useradd payara && chown -R payara:payara /usr/local/payara5

# install maven
RUN curl -L -O ${MAVEN_URL}
RUN mkdir /opt/maven && bsdtar --strip-components=1 -C /opt/maven -xf /apache-maven-3.*
RUN echo "export JAVA_HOME=/usr/lib/jvm/jre-openjdk" > /etc/profile.d/maven.sh && \
    echo "export M2_HOME=/opt/maven" >> /etc/profile.d/maven.sh && \
    echo "export MAVEN_HOME=/opt/maven" >> /etc/profile.d/maven.sh && \
    echo "export PATH=${M2_HOME}/bin:${PATH}" >> /etc/profile.d/maven.sh

# copy configuration related files
#RUN cp /tmp/dv/solrconfig.xml /opt/solr-7.7.2/server/solr/collection1/conf/solrconfig.xml

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

# TODO: convert these to default.config
#ARG DoiProvider=EZID
#ARG DoiProvider=FAKE
#ARG doi_baseurl=https://ezid.cdlib.org
#ARG doi_username=apitest
#ARG doi_password=apitest
#ENV DoiProvider=${DoiProvider}
#ENV doi_baseurl=${doi_baseurl}
#ENV doi_username=${doi_username}
#ENV doi_password=${doi_password}
#COPY configure_doi.bash /opt/dv

CMD ["/entrypoint.bash"]
