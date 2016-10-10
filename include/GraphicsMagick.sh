#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_GraphicsMagick() {
cd $oneinstack_dir/src
tar xzf GraphicsMagick-$GraphicsMagick_version.tar.gz
cd GraphicsMagick-$GraphicsMagick_version
./configure --prefix=/usr/local/graphicsmagick --enable-shared --enable-static
make -j ${THREAD} && make install
cd ..
rm -rf GraphicsMagick-$GraphicsMagick_version
cd ..
}

Install_php-gmagick() {
cd $oneinstack_dir/src
phpExtensionDir=$($php_install_dir/bin/php-config --extension-dir)
if [ -e "$php_install_dir/bin/phpize" ];then
    if [ "`$php_install_dir/bin/php -r 'echo PHP_VERSION;' | awk -F. '{print $1}'`" == '7' ];then
        tar xzf gmagick-2.0.4RC1.tgz
        cd gmagick-2.0.4RC1
    else
        tar xzf gmagick-$gmagick_version.tgz
        cd gmagick-$gmagick_version
    fi
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
    $php_install_dir/bin/phpize
    ./configure --with-php-config=$php_install_dir/bin/php-config --with-gmagick=/usr/local/graphicsmagick
    make -j ${THREAD} && make install
    cd ..
    rm -rf gmagick-$gmagick_version

    if [ -f "${phpExtensionDir}/gmagick.so" ];then
        cat > $php_install_dir/etc/php.d/ext-gmagick.ini << EOF
[gmagick]
extension=gmagick.so
EOF
        [ "$Apache_version" != '1' -a "$Apache_version" != '2' ] && service php-fpm restart || service httpd restart
    else
        echo "${CFAILURE}PHP gmagick module install failed, Please contact the author! ${CEND}"
    fi
fi
  # Clean up
  rm -rf gmagick-${gmagick_for_php7_version}
  rm -rf gmagick-${gmagick_version}
cd ..
}
