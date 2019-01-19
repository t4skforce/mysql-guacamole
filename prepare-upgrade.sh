#!/bin/bash
mkdir -p /docker-entrypoint-upgrade.d/
for filename in ./schema/upgrade/upgrade-pre-*.sql; do
	version=$(echo $filename | awk -F"-" '{ print $3 }' | awk -F"." '{ printf("%02d%02d%02d\n",$1,$2,$3) }')
	mv $filename /docker-entrypoint-upgrade.d/999-upgrade-${version}.sql
done
