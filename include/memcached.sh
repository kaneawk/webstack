#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_memcached() {
  pushd ${oneinstack_dir}/src

  # memcached server
  id -u memcached >/dev/null 2>&1
  [ $? -ne 0 ] && useradd -M -s /sbin/nologin memcached

  tar xzf memcached-${memcached_version}.tar.gz
  pushd memcached-${memcached_version}
  [ ! -d "${memcached_install_dir}" ] && mkdir -p ${memcached_install_dir}
  ./configure --prefix=${memcached_install_dir}
  make -j ${THREAD} && make install
  popd
  if [ -d "${memcached_install_dir}/include/memcached" ]; then
    echo "${CSUCCESS}memcached installed successfully! ${CEND}"
    rm -rf memcached-${memcached_version}
    ln -s ${memcached_install_dir}/bin/memcached /usr/bin/memcached
    [ "${OS}" == "CentOS" ] && { /bin/cp ../init.d/Memcached-init-CentOS /etc/init.d/memcached; chkconfig --add memcached; chkconfig memcached on; }
    [[ "${OS}" =~ ^Ubuntu$|^Debian$ ]] && { /bin/cp ../init.d/Memcached-init-Ubuntu /etc/init.d/memcached; update-rc.d memcached defaults; }
    sed -i "s@/usr/local/memcached@${memcached_install_dir}@g" /etc/init.d/memcached
    [ -n "`grep 'CACHESIZE=' /etc/init.d/memcached`" ] && sed -i "s@^CACHESIZE=.*@CACHESIZE=`expr $Mem / 8`@" /etc/init.d/memcached
    [ -n "`grep 'start_instance default 256;' /etc/init.d/memcached`" ] && sed -i "s@start_instance default 256;@start_instance default `expr $Mem / 8`;@" /etc/init.d/memcached
    service memcached start
  else
    rm -rf memcached-${memcached_version}
    rm -rf ${memcached_install_dir}
    echo "${CFAILURE}memcached install failed, Please contact the author! ${CEND}"
    kill -9 $$
  fi
  popd
}

Install_php-memcache() {
  pushd ${oneinstack_dir}/src
  phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    # php memcache extension
    if [ "$(${php_install_dir}/bin/php -r 'echo PHP_VERSION;' | awk -F. '{print $1}')" == '7' ]; then
      #git clone https://github.com/websupport-sk/pecl-memcache.git
      #cd pecl-memcache
      tar xzf pecl-memcache-php7.tgz
      pushd pecl-memcache-php7
    else
      tar xzf memcache-${memcache_pecl_version}.tgz
      pushd memcache-${memcache_pecl_version}
    fi
    ${php_install_dir}/bin/phpize
    ./configure --with-php-config=${php_install_dir}/bin/php-config
    make -j ${THREAD} && make install
    popd
    if [ -f "${phpExtensionDir}/memcache.so" ]; then
      cat > ${php_install_dir}/etc/php.d/ext-memcache.ini << EOF
extension=memcache.so
EOF
      [ "${Apache_version}" != '1' -a "${Apache_version}" != '2' ] && service php-fpm restart || service httpd restart
      echo "${CSUCCESS}PHP memcache module installed successfully! ${CEND}"
    else
      echo "${CFAILURE}PHP memcache module install failed, Please contact the author! ${CEND}"
    fi
  fi
  # Clean up
  rm -rf pecl-memcache-php7
  rm -rf memcache-${memcache_pecl_version}
  popd
}

Install_php-memcached() {
  pushd ${oneinstack_dir}/src
  phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    # php memcached extension
    tar xzf libmemcached-${libmemcached_version}.tar.gz
    pushd libmemcached-${libmemcached_version}
    [ "${OS}" == "CentOS" ] && yum -y install cyrus-sasl-devel
    [[ "${OS}" =~ ^Ubuntu$|^Debian$ ]] && sed -i "s@lthread -pthread -pthreads@lthread -lpthread -pthreads@" ./configure
    ./configure --with-memcached=${memcached_install_dir}
    make -j ${THREAD} && make install
    popd
    rm -rf libmemcached-${libmemcached_version}

    if [ "$(${php_install_dir}/bin/php -r 'echo PHP_VERSION;' | awk -F. '{print $1}')" == '7' ]; then
      #git clone -b php7 https://github.com/php-memcached-dev/php-memcached.git
      #cd php-memcached
      tar xzf php-memcached-php7.tgz
      pushd php-memcached-php7
    else
      tar xzf memcached-${memcached_pecl_version}.tgz
      pushd memcached-${memcached_pecl_version}
    fi
    ${php_install_dir}/bin/phpize
    ./configure --with-php-config=${php_install_dir}/bin/php-config
    make -j ${THREAD} && make install
    popd
    if [ -f "${phpExtensionDir}/memcached.so" ]; then
        cat > ${php_install_dir}/etc/php.d/ext-memcached.ini << EOF
extension=memcached.so
memcached.use_sasl=1
EOF
      echo "${CSUCCESS}PHP memcached module installed successfully! ${CEND}"
      [ "${Apache_version}" != '1' -a "${Apache_version}" != '2' ] && service php-fpm restart || service httpd restart
    else
      echo "${CFAILURE}PHP memcached module install failed, Please contact the author! ${CEND}"
    fi
  fi
  # Clean up
  rm -rf php-memcached-php7
  rm -rf memcached-${memcached_pecl_version}
  popd
}
