#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_ImageMagick() {
  pushd ${oneinstack_dir}/src
  tar xzf ImageMagick-${ImageMagick_version}.tar.gz
  pushd ImageMagick-${ImageMagick_version}
  ./configure --prefix=/usr/local/imagemagick --enable-shared --enable-static
  make -j ${THREAD} && make install
  popd
  rm -rf ImageMagick-${ImageMagick_version}
  popd
}

Install_php-imagick() {
  pushd ${oneinstack_dir}/src
  phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    if [ "$(${php_install_dir}/bin/php -r 'echo PHP_VERSION;' | awk -F. '{print $1"."$2}')" == '5.3' ]; then
      tar xzf imagick-${imagick_for_php53_version}.tgz
      pushd imagick-${imagick_for_php53_version}
    else
      tar xzf imagick-${imagick_version}.tgz
      pushd imagick-${imagick_version}
    fi
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
    ${php_install_dir}/bin/phpize
    ./configure --with-php-config=${php_install_dir}/bin/php-config --with-imagick=/usr/local/imagemagick
    make -j ${THREAD} && make install
    popd

    if [ -f "${phpExtensionDir}/imagick.so" ]; then
      cat > ${php_install_dir}/etc/php.d/ext-imagick.ini << EOF
[imagick]
extension=imagick.so
EOF
      [ "${Apache_version}" != '1' -a "${Apache_version}" != '2' ] && service php-fpm restart || service httpd restart
    else
      echo "${CFAILURE}PHP imagick module install failed, Please contact the author! ${CEND}"
    fi
  fi
  # Clean up
  rm -rf imagick-${imagick_version}
  rm -rf imagick-${imagick_for_php53_version}
  popd
}
