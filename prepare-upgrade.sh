#!/bin/bash
mkdir -p /docker-entrypoint-upgradedb.d/
for filename in ./upgrade/upgrade-pre-*.sql; do
	version=$(echo $filename | awk -F"-" '{ print $3 }' | awk -F"." '{ printf("%02d%02d%02d\n",$1,$2,$3) }')
	mv $filename /upgrade/999-upgrade-${version}.sql
done
