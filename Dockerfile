FROM mariadb:10

########################################
#               Build                  #
########################################
ARG VERSION="1.0.0"
ARG DOWNLOADURL="https://github.com/apache/guacamole-client/archive/1.0.0.tar.gz"
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
  && head -n -1 /usr/local/bin/docker-entrypoint.sh > /usr/local/bin/docker-entrypoint.sh.tmp \
  && cat /tmp/docker-entrypoint-patch.sh >> /usr/local/bin/docker-entrypoint.sh.tmp \
  && mv /usr/local/bin/docker-entrypoint.sh.tmp /usr/local/bin/docker-entrypoint.sh \
  && chmod +x /usr/local/bin/docker-entrypoint.sh \
  && apt-get --auto-remove -y purge curl \
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*
