FROM mariadb:10

########################################
#               Build                  #
########################################
ARG VERSION="1.0.0"
ARG DOWNLOADURL="https://github.com/apache/guacamole-client/archive/1.0.0.tar.gz"
########################################

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp/
RUN apt-get update -qqy \
  && apt-get -qqy install curl \
  && curl -Ls ${DOWNLOADURL} --output guacamole-client.tar.gz \
  && tar -zxf /tmp/guacamole-client.tar.gz \
  && rm guacamole-client.tar.gz \
  && cp /tmp/guacamole-client-*/extensions/guacamole-auth-jdbc/modules/guacamole-auth-jdbc-mysql/schema/*.sql /docker-entrypoint-initdb.d/ \
  && echo 'sed -i "1i USE $MYSQL_DATABASE;" /docker-entrypoint-initdb.d/*.sql' > /docker-entrypoint-initdb.d/000-use-database.sh \
  && chmod 777 -R /docker-entrypoint-initdb.d/ \
  && apt-get --auto-remove -y purge curl \
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*
