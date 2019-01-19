
if [ "$1" = 'mysqld' -a -z "$wantHelp" ]; then
  # still need to check config, container may have started with --user
  _check_config "$@"
  
  if [ ! -z "$MYSQL_ROOT_PASSWORD" ]; then
    mysql+=( -p"${MYSQL_ROOT_PASSWORD}" )
  fi

  file_env 'MYSQL_DATABASE'
  if [ "$MYSQL_DATABASE" ]; then
    echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` ;" | "${mysql[@]}"
    mysql+=( "$MYSQL_DATABASE" )
  fi
  
  echo 'Upgrading database'
  for f in /docker-entrypoint-upgrade.d/*; do
    case "$f" in
      *.sh)
        if [ $(echo "SELECT count(1) FROM auto_updates WHERE scriptname='${f}';" | "${mysql[@]}") = "0" ]; then
          echo "$0: running $f";
          . "$f"
          echo "INSERT INTO auto_updates (scriptname) VALUES ('${f}');" | "${mysql[@]}"
        else
          echo "$0: ignoring $f"
        fi
        echo 
      ;;
      *.sql)
        if [ $(echo "SELECT count(1) FROM auto_updates WHERE scriptname='${f}';" | "${mysql[@]}") = "0" ]; then
          echo "$0: running $f";
          "${mysql[@]}" < "$f";
          echo "INSERT INTO auto_updates (scriptname) VALUES ('${f}');" | "${mysql[@]}"
        else
          echo "$0: ignoring $f"
        fi 
        echo 
      ;;
      *.sql.gz)
        if [ $(echo "SELECT count(1) FROM auto_updates WHERE scriptname='${f}';" | "${mysql[@]}") = "0" ]; then
          echo "$0: running $f";
          gunzip -c "$f" | "${mysql[@]}";
          echo "INSERT INTO auto_updates (scriptname) VALUES ('${f}');" | "${mysql[@]}"
        else
          echo "$0: ignoring $f"
        fi
        echo 
      ;;
      *)        
        echo "$0: ignoring $f" 
      ;;
    esac
    echo
  done
  
  echo
  echo 'MySQL update process done. Ready for start up.'
  echo
fi

exec "$@"
