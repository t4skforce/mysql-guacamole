FROM mariadb:10

########################################
#               Build                  #
########################################
ARG VERSION="1.4.0"
ARG DOWNLOADURL="https://github.com/apache/guacamole-client/archive/1.4.0.tar.gz"
ARG BUILD_DATE="2022-03-06T10:09:21Z"
########################################

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp/
COPY /prepare-upgrade.sh /tmp/prepare-upgrade.sh
COPY /docker-entrypoint-patch.sh /tmp/docker-entrypoint-patch.sh
RUN apt-get update -qqy \
  && apt-get -qqy install curl \
  && curl -Ls ${DOWNLOADURL} --output guacamole-client.tar.gz \
  && tar -zxf /tmp/guacamole-client.tar.gz \
  && rm guacamole-client.tar.gz \
  && cd /tmp/guacamole-client-*/extensions/guacamole-auth-jdbc/modules/guacamole-auth-jdbc-mysql/ \
  && cp ./schema/*.sql /docker-entrypoint-initdb.d/ \
  && chmod +x /tmp/prepare-upgrade.sh && /tmp/prepare-upgrade.sh \
  && chmod a+rw -R /docker-entrypoint-initdb.d/ /docker-entrypoint-upgrade.d/ \
  && cat /tmp/docker-entrypoint-patch.sh > /usr/local/bin/docker-entrypoint.sh \
  && chmod +x /usr/local/bin/docker-entrypoint.sh \
  && apt-get --auto-remove -y purge curl \
  && rm -rf /tmp/* \
            /var/lib/apt/lists/* \
            /var/log/dpkg.log \
            /var/log/apt/*
