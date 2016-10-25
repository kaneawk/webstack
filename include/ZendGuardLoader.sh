#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_ZendGuardLoader() {
  pushd ${oneinstack_dir}/src

  PHP_detail_version=$(${php_install_dir}/bin/php -r 'echo PHP_VERSION;')
  PHP_main_version=${PHP_detail_version%.*}
  phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
  [ ! -d "${phpExtensionDir}" ] && mkdir -p ${phpExtensionDir}
  if [ "${OS_BIT}" == "64" ]; then
    case "${PHP_main_version}" in
      5.6)
        tar xzf zend-loader-php5.6-linux-x86_64.tar.gz
        /bin/cp zend-loader-php5.6-linux-x86_64/ZendGuardLoader.so ${phpExtensionDir}
        rm -rf zend-loader-php5.6-linux-x86_64
        ;;
      5.5)
        tar xzf zend-loader-php5.5-linux-x86_64.tar.gz
        /bin/cp zend-loader-php5.5-linux-x86_64/ZendGuardLoader.so ${phpExtensionDir}
        rm -rf zend-loader-php5.5-linux-x86_64
        ;;
      5.4)
        tar xzf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
        /bin/cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64/php-5.4.x/ZendGuardLoader.so ${phpExtensionDir}
        rm -rf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64
        ;;
      5.3)
        tar xzf ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
        /bin/cp ZendGuardLoader-php-5.3-linux-glibc23-x86_64/php-5.3.x/ZendGuardLoader.so ${phpExtensionDir}
        rm -rf ZendGuardLoader-php-5.3-linux-glibc23-x86_64
        ;;
    esac
  else
    case "${PHP_main_version}" in
      5.6)
        tar xzf zend-loader-php5.6-linux-i386.tar.gz
        /bin/cp zend-loader-php5.6-linux-i386/ZendGuardLoader.so ${phpExtensionDir}
        rm -rf zend-loader-php5.6-linux-i386
        ;;
      5.5)
        tar xzf zend-loader-php5.5-linux-i386.tar.gz
        /bin/cp zend-loader-php5.5-linux-i386/ZendGuardLoader.so ${phpExtensionDir}
        rm -rf zend-loader-php5.5-linux-x386
        ;;
      5.4)
        tar xzf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz
        /bin/cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386/php-5.4.x/ZendGuardLoader.so ${phpExtensionDir}
        rm -rf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386
        ;;
      5.3)
        tar xzf ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
        /bin/cp ZendGuardLoader-php-5.3-linux-glibc23-i386/php-5.3.x/ZendGuardLoader.so ${phpExtensionDir}
        rm -rf ZendGuardLoader-php-5.3-linux-glibc23-i386
        ;;
    esac
  fi

  if [ -f "${phpExtensionDir}/ZendGuardLoader.so" ]; then
    cat > ${php_install_dir}/etc/php.d/ext-ZendGuardLoader.ini << EOF
[Zend Guard Loader]
zend_extension=${phpExtensionDir}/ZendGuardLoader.so
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
EOF
    echo "${CSUCCESS}PHP ZendGuardLoader module installed successfully! ${CEND}"
    [ "${Apache_version}" != '1' -a "${Apache_version}" != '2' ] && service php-fpm restart || service httpd restart
  else
    echo "${CFAILURE}PHP ZendGuardLoader module install failed, Please contact the author! ${CEND}"
  fi
  popd
}
