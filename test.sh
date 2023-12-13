#!/bin/bash
MYSQL_ROOT_PASS="Mysql_1234"

# set timezone to UTC to init timestamp data
mysql -uroot -p$MYSQL_ROOT_PASS -e "SET GLOBAL time_zone = '+00:00';"
mysql -uroot -p$MYSQL_ROOT_PASS -e "SET GLOBAL log_bin_trust_function_creators = 1;"
mysql -uroot -p$MYSQL_ROOT_PASS -e "SET GLOBAL local_infile=1;"

./mysql_init.sh

sed -i 's/REGRESS =.*/REGRESS = mysql_fdw server_options connection_validation dml select pushdown selectfunc mysql_fdw_post join_pushdown aggregate_pushdown extra\/aggregates/' Makefile


make clean
make $1
make check $1 | tee make_check.out