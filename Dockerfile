FROM mysql

########################################
#               Build                  #
########################################
ARG VERSION="0.9.14"
ARG DOWNLOADURL="https://github.com/apache/guacamole-client/archive/0.9.14.tar.gz"
########################################

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp/
RUN apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install curl \
  && curl -Ls ${DOWNLOADURL} --output guacamole-client.tar.gz \
  && tar -zxf guacamole-client.tar.gz \
  && rm guacamole-client.tar.gz \
  && cp /tmp/guacamole-client-*/extensions/guacamole-auth-jdbc/modules/guacamole-auth-jdbc-mysql/schema/*.sql /docker-entrypoint-initdb.d/ \
  && echo 'sed -i "1i USE $MYSQL_DATABASE;" /docker-entrypoint-initdb.d/*.sql' > /docker-entrypoint-initdb.d/000-use-database.sh \
  && chmod 777 -R /docker-entrypoint-initdb.d/ \
  && apt-get remove --purge curl
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*
