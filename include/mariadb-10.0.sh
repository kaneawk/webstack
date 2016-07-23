#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_MariaDB-10-0() {
cd $oneinstack_dir/src

FILE_NAME=mariadb-${mariadb_10_0_version}-${GLIBC_FLAG}-${SYS_BIT_b}.tar.gz

if [ "$IPADDR_COUNTRY"x == "CN"x ];then
    DOWN_ADDR_MARIADB=http://mirrors.aliyun.com/mariadb/mariadb-${mariadb_10_0_version}/bintar-${GLIBC_FLAG}-$SYS_BIT_a
    MARAIDB_TAR_MD5=`curl -Lk $DOWN_ADDR_MARIADB/md5sums.txt | grep $FILE_NAME | awk '{print $1}'`
    [ -z "$MARAIDB_TAR_MD5" ] && { DOWN_ADDR_MARIADB=https://mirrors.ustc.edu.cn/mariadb/mariadb-${mariadb_10_0_version}/bintar-${GLIBC_FLAG}-$SYS_BIT_a; MARAIDB_TAR_MD5=`curl -Lk $DOWN_ADDR_MARIADB/md5sums.txt | grep $FILE_NAME | awk '{print $1}'`; }
else
    DOWN_ADDR_MARIADB=https://downloads.mariadb.org/interstitial/mariadb-${mariadb_10_0_version}/bintar-${GLIBC_FLAG}-$SYS_BIT_a
    MARAIDB_TAR_MD5=`curl -Lk http://archive.mariadb.org/mariadb-${mariadb_10_0_version}/bintar-${GLIBC_FLAG}-$SYS_BIT_a/md5sums.txt |  grep $FILE_NAME | awk '{print $1}'`
fi

src_url=$DOWN_ADDR_MARIADB/$FILE_NAME && Download_src

while [ "`md5sum $FILE_NAME | awk '{print $1}'`" != "$MARAIDB_TAR_MD5" ];
do
    wget -c --no-check-certificate $DOWN_ADDR_MARIADB/$FILE_NAME;sleep 1
    [ "`md5sum $FILE_NAME | awk '{print $1}'`" == "$MARAIDB_TAR_MD5" ] && break || continue
done

id -u mysql >/dev/null 2>&1
[ $? -ne 0 ] && useradd -M -s /sbin/nologin mysql

mkdir -p $mariadb_data_dir;chown mysql.mysql -R $mariadb_data_dir
tar zxf mariadb-${mariadb_10_0_version}-${GLIBC_FLAG}-${SYS_BIT_b}.tar.gz
[ ! -d "$mariadb_install_dir" ] && mkdir -p $mariadb_install_dir
mv mariadb-${mariadb_10_0_version}-*-${SYS_BIT_b}/* $mariadb_install_dir
if [ "$je_tc_malloc" == '1' ];then
    sed -i 's@executing mysqld_safe@executing mysqld_safe\nexport LD_PRELOAD=/usr/local/lib/libjemalloc.so@' $mariadb_install_dir/bin/mysqld_safe
elif [ "$je_tc_malloc" == '2' ];then
    sed -i 's@executing mysqld_safe@executing mysqld_safe\nexport LD_PRELOAD=/usr/local/lib/libtcmalloc.so@' $mariadb_install_dir/bin/mysqld_safe
fi

if [ -d "$mariadb_install_dir/support-files" ];then
    echo "${CSUCCESS}MariaDB installed successfully! ${CEND}"
else
    rm -rf $mariadb_install_dir
    echo "${CFAILURE}MariaDB install failed, Please contact the author! ${CEND}"
    kill -9 $$
fi

/bin/cp $mariadb_install_dir/support-files/mysql.server /etc/init.d/mysqld
sed -i "s@^basedir=.*@basedir=$mariadb_install_dir@" /etc/init.d/mysqld
sed -i "s@^datadir=.*@datadir=$mariadb_data_dir@" /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
[ "$OS" == 'CentOS' ] && { chkconfig --add mysqld; chkconfig mysqld on; }
[[ $OS =~ ^Ubuntu$|^Debian$ ]] && update-rc.d mysqld defaults
cd ..

# my.cnf
[ -d "/etc/mysql" ] && /bin/mv /etc/mysql{,_bk}
cat > /etc/my.cnf << EOF
[client]
port = 3306
socket = /tmp/mysql.sock
default-character-set = utf8mb4

[mysqld]
port = 3306
socket = /tmp/mysql.sock

basedir = $mariadb_install_dir
datadir = $mariadb_data_dir
pid-file = $mariadb_data_dir/mysql.pid
user = mysql
bind-address = 0.0.0.0
server-id = 1

init-connect = 'SET NAMES utf8mb4'
character-set-server = utf8mb4

skip-name-resolve
#skip-networking
back_log = 300

max_connections = 1000
max_connect_errors = 6000
open_files_limit = 65535
table_open_cache = 128
max_allowed_packet = 500M
binlog_cache_size = 1M
max_heap_table_size = 8M
tmp_table_size = 16M

read_buffer_size = 2M
read_rnd_buffer_size = 8M
sort_buffer_size = 8M
join_buffer_size = 8M
key_buffer_size = 4M

thread_cache_size = 8

query_cache_type = 1
query_cache_size = 8M
query_cache_limit = 2M

ft_min_word_len = 4

log_bin = mysql-bin
binlog_format = mixed
expire_logs_days = 7

log_error = $mariadb_data_dir/mysql-error.log
slow_query_log = 1
long_query_time = 1
slow_query_log_file = $mariadb_data_dir/mysql-slow.log

performance_schema = 0

#lower_case_table_names = 1

skip-external-locking

default_storage_engine = InnoDB
innodb_file_per_table = 1
innodb_open_files = 500
innodb_buffer_pool_size = 64M
innodb_write_io_threads = 4
innodb_read_io_threads = 4
innodb_thread_concurrency = 0
innodb_purge_threads = 1
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 2M
innodb_log_file_size = 32M
innodb_log_files_in_group = 3
innodb_max_dirty_pages_pct = 90
innodb_lock_wait_timeout = 120

bulk_insert_buffer_size = 8M
myisam_sort_buffer_size = 8M
myisam_max_sort_file_size = 10G
myisam_repair_threads = 1

interactive_timeout = 28800
wait_timeout = 28800

[mysqldump]
quick
max_allowed_packet = 500M

[myisamchk]
key_buffer_size = 8M
sort_buffer_size = 8M
read_buffer = 4M
write_buffer = 4M
EOF

sed -i "s@max_connections.*@max_connections = $(($Mem/2))@" /etc/my.cnf
if [ $Mem -gt 1500 -a $Mem -le 2500 ];then
    sed -i 's@^thread_cache_size.*@thread_cache_size = 16@' /etc/my.cnf
    sed -i 's@^query_cache_size.*@query_cache_size = 16M@' /etc/my.cnf
    sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 16M@' /etc/my.cnf
    sed -i 's@^key_buffer_size.*@key_buffer_size = 16M@' /etc/my.cnf
    sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 128M@' /etc/my.cnf
    sed -i 's@^tmp_table_size.*@tmp_table_size = 32M@' /etc/my.cnf
    sed -i 's@^table_open_cache.*@table_open_cache = 256@' /etc/my.cnf
elif [ $Mem -gt 2500 -a $Mem -le 3500 ];then
    sed -i 's@^thread_cache_size.*@thread_cache_size = 32@' /etc/my.cnf
    sed -i 's@^query_cache_size.*@query_cache_size = 32M@' /etc/my.cnf
    sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 32M@' /etc/my.cnf
    sed -i 's@^key_buffer_size.*@key_buffer_size = 64M@' /etc/my.cnf
    sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 512M@' /etc/my.cnf
    sed -i 's@^tmp_table_size.*@tmp_table_size = 64M@' /etc/my.cnf
    sed -i 's@^table_open_cache.*@table_open_cache = 512@' /etc/my.cnf
elif [ $Mem -gt 3500 ];then
    sed -i 's@^thread_cache_size.*@thread_cache_size = 64@' /etc/my.cnf
    sed -i 's@^query_cache_size.*@query_cache_size = 64M@' /etc/my.cnf
    sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 64M@' /etc/my.cnf
    sed -i 's@^key_buffer_size.*@key_buffer_size = 256M@' /etc/my.cnf
    sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 1024M@' /etc/my.cnf
    sed -i 's@^tmp_table_size.*@tmp_table_size = 128M@' /etc/my.cnf
    sed -i 's@^table_open_cache.*@table_open_cache = 1024@' /etc/my.cnf
fi

$mariadb_install_dir/scripts/mysql_install_db --user=mysql --basedir=$mariadb_install_dir --datadir=$mariadb_data_dir

chown mysql.mysql -R $mariadb_data_dir
[ -d '/etc/mysql' ] && mv /etc/mysql{,_bk}
service mysqld start
[ -z "`grep ^'export PATH=' /etc/profile`" ] && echo "export PATH=$mariadb_install_dir/bin:\$PATH" >> /etc/profile
[ -n "`grep ^'export PATH=' /etc/profile`" -a -z "`grep $mariadb_install_dir /etc/profile`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=$mariadb_install_dir/bin:\1@" /etc/profile
. /etc/profile

$mariadb_install_dir/bin/mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by \"$dbrootpwd\" with grant option;"
$mariadb_install_dir/bin/mysql -e "grant all privileges on *.* to root@'localhost' identified by \"$dbrootpwd\" with grant option;"
$mariadb_install_dir/bin/mysql -uroot -p$dbrootpwd -e "delete from mysql.user where Password='';"
$mariadb_install_dir/bin/mysql -uroot -p$dbrootpwd -e "delete from mysql.db where User='';"
$mariadb_install_dir/bin/mysql -uroot -p$dbrootpwd -e "delete from mysql.proxies_priv where Host!='localhost';"
$mariadb_install_dir/bin/mysql -uroot -p$dbrootpwd -e "drop database test;"
$mariadb_install_dir/bin/mysql -uroot -p$dbrootpwd -e "reset master;"
rm -rf /etc/ld.so.conf.d/{mysql,mariadb,percona}*.conf
echo "$mariadb_install_dir/lib" > /etc/ld.so.conf.d/mariadb.conf
ldconfig
service mysqld stop
}
