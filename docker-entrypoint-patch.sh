
if [ "$1" = 'mysqld' -a -z "$wantHelp" ]; then
  # still need to check config, container may have started with --user
  _check_config "$@"
  # Get config
  DATADIR="$(_get_config 'datadir' "$@")"

  if [ -d "$DATADIR/mysql" ]; then  
    SOCKET="$(_get_config 'socket' "$@")"
    "$@" --skip-networking --socket="${SOCKET}" &
    pid="$!"

    mysql=( mysql --protocol=socket -uroot -hlocalhost --socket="${SOCKET}" )
    
    file_env 'MYSQL_ROOT_PASSWORD'
    if [ ! -z "$MYSQL_ROOT_PASSWORD" ]; then
      mysql+=( -p"${MYSQL_ROOT_PASSWORD}" )
    fi
    
    for i in {30..0}; do
      if echo 'SELECT 1' | "${mysql[@]}" &> /dev/null; then
        break
      fi
      echo 'MySQL update process in progress...'
      sleep 1
    done
    if [ "$i" = 0 ]; then
      echo >&2 'MySQL update process failed.'
    fi
    
    # to run update scripts even if parts fail
    mysql+=( "--force" )

    file_env 'MYSQL_DATABASE'
    if [ "$MYSQL_DATABASE" ]; then
      echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` ;" | "${mysql[@]}"
      mysql+=( "$MYSQL_DATABASE" )
    fi
    
    echo "CREATE TABLE IF NOT EXISTS \`auto_updates\` (\`hash\` varchar(32) NOT NULL UNIQUE) ENGINE=InnoDB DEFAULT CHARSET=utf8;" | "${mysql[@]}"
  
    echo 'Upgrading database'
    for f in /docker-entrypoint-upgrade.d/*; do
      case "$f" in
        *.sh)
	  md5=$(md5sum "${f}" | awk '{ print $1 }')
          if [ $(echo "SELECT count(1) FROM auto_updates WHERE hash='${md5}';" | "${mysql[@]}") = "0" ]; then
            echo "$0: running $f";
            . "$f"
	    rm "$f"
            echo "INSERT INTO \`auto_updates\` (\`hash\`) VALUES ('${md5}');" | "${mysql[@]}" &> /dev/null
          else
            echo "$0: already ran $f ignoring"
          fi
          echo 
        ;;
        *.sql)
	  md5=$(md5sum "${f}" | awk '{ print $1 }')
          if [ $(echo "SELECT count(1) FROM auto_updates WHERE hash='${md5}';" | "${mysql[@]}") = "0" ]; then
            echo "$0: running $f";
            "${mysql[@]}" < "$f";
            echo "INSERT INTO \`auto_updates\` (\`hash\`) VALUES ('${md5}');" | "${mysql[@]}" &> /dev/null
          else
            echo "$0: already ran $f ignoring"
          fi 
          echo 
        ;;
        *.sql.gz)
	  md5=$(md5sum "${f}" | awk '{ print $1 }')
          if [ $(echo "SELECT count(1) FROM auto_updates WHERE hash='${md5}';" | "${mysql[@]}") = "0" ]; then
            echo "$0: running $f";
            gunzip -c "$f" | "${mysql[@]}";
            echo "INSERT INTO \`auto_updates\` (\`hash\`) VALUES ('${md5}');" | "${mysql[@]}" &> /dev/null
          else
            echo "$0: already ran $f ignoring"
          fi
          echo 
        ;;
        *)        
          echo "$0: ignoring $f" 
        ;;
      esac
      echo
    done
  
    if ! kill -s TERM "$pid" || ! wait "$pid"; then
      echo >&2 'MySQL update process failed.'
    fi
  
    echo
    echo 'MySQL update process done. Ready for start up.'
    echo
  fi
fi

exec "$@"
