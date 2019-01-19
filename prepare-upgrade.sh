#!/bin/bash

# generate ordered upgrade.sql files
mkdir -p /docker-entrypoint-upgrade.d/
for filename in ./schema/upgrade/upgrade-pre-*.sql; do
	version=$(echo $filename | awk -F"-" '{ print $3 }' | awk -F"." '{ printf("%02d%02d%02d\n",$1,$2,$3) }')
	mv $filename /docker-entrypoint-upgrade.d/000-upgrade-${version}.sql
done

# generate init.sql so upgrades are not run after init
echo "CREATE TABLE IF NOT EXISTS \`auto_updates\` (\`hash\` varchar(32) NOT NULL UNIQUE) ENGINE=InnoDB DEFAULT CHARSET=utf8;" > /docker-entrypoint-initdb.d/999-upgrade.sql
for f in /docker-entrypoint-upgrade.d/*; do
  md5=$(md5sum "${f}" | awk '{ print $1 }')
  echo "INSERT INTO \`auto_updates\` (\`hash\`) VALUES ('${md5}');" >> /docker-entrypoint-initdb.d/999-upgrade.sql
done
