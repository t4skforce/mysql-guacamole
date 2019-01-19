
if [ "$1" = 'mysqld' -a -z "$wantHelp" ]; then
	# still need to check config, container may have started with --user
	_check_config "$@"
  
  echo 'Upgrading database'
  for f in /docker-entrypoint-upgrade.d/*; do
    case "$f" in
      *.sh)
        if [ $(echo "SELECT count(1) FROM auto_updates WHERE scriptname='${f}';" | "${mysql[@]}") -eq 0 ]; then
          echo "$0: running $f";
          . "$f"
          echo "INSERT INTO auto_updates (scriptname) VALUES ('${f}');" | "${mysql[@]}"
        else
          echo "$0: ignoring $f"
        fi
        echo 
      ;;
      *.sql)
        if [ $(echo "SELECT count(1) FROM auto_updates WHERE scriptname='${f}';" | "${mysql[@]}") -eq 0 ]; then
          echo "$0: running $f";
          "${mysql[@]}" < "$f";
          echo "INSERT INTO auto_updates (scriptname) VALUES ('${f}');" | "${mysql[@]}"
        else
          echo "$0: ignoring $f"
        fi 
        echo 
      ;;
      *.sql.gz)
        if [ $(echo "SELECT count(1) FROM auto_updates WHERE scriptname='${f}';" | "${mysql[@]}") -eq 0 ]; then
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
