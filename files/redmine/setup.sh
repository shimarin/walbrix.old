#!/bin/sh
cd /var/www/localhost/htdocs
export RUBY_GC_MALLOC_LIMIT=90000000 RAILS_ENV=production REDMINE_LANG=ja
rake generate_secret_token || exit 1
rake db:migrate || exit 1
rake redmine:load_default_data || exit 1
mysql --socket=$MYSQL_UNIX_PORT -u redmine redmine -e "update users set language='ja' where id=1" || exit 1
mysql --socket=$MYSQL_UNIX_PORT -u redmine redmine -e "insert into settings(name,value,updated_on) values('default_language','ja',now())" || exit 1

