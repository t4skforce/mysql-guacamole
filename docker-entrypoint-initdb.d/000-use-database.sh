sed -i "1i USE $MYSQL_DATABASE;" /docker-entrypoint-initdb.d/*.sql
