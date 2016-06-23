#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Upgrade_Nginx() {
cd $oneinstack_dir/src
[ ! -e "$nginx_install_dir/sbin/nginx" ] && echo "${CWARNING}Nginx is not installed on your system! ${CEND}" && exit 1
OLD_Nginx_version_tmp=`$nginx_install_dir/sbin/nginx -v 2>&1`
OLD_Nginx_version=${OLD_Nginx_version_tmp##*/}
echo
echo "Current Nginx Version: ${CMSG}$OLD_Nginx_version${CEND}"
while :; do echo
    read -p "Please input upgrade Nginx Version(example: 1.9.15): " NEW_Nginx_version
    if [ "$NEW_Nginx_version" != "$OLD_Nginx_version" ];then
        [ ! -e "nginx-$NEW_Nginx_version.tar.gz" ] && wget --no-check-certificate -c http://nginx.org/download/nginx-$NEW_Nginx_version.tar.gz > /dev/null 2>&1
        if [ -e "nginx-$NEW_Nginx_version.tar.gz" ];then
            src_url=https://www.openssl.org/source/openssl-$openssl_version.tar.gz && Download_src
            src_url=http://mirrors.linuxeye.com/oneinstack/src/pcre-$pcre_version.tar.gz && Download_src
            tar xzf openssl-$openssl_version.tar.gz
            tar xzf pcre-$pcre_version.tar.gz
            echo "Download [${CMSG}nginx-$NEW_Nginx_version.tar.gz${CEND}] successfully! "
            break
        else
            echo "${CWARNING}Nginx version does not exist! ${CEND}"
        fi
    else
        echo "${CWARNING}input error! Upgrade Nginx version is the same as the old version${CEND}"
    fi
done

if [ -e "nginx-$NEW_Nginx_version.tar.gz" ];then
    echo "[${CMSG}nginx-$NEW_Nginx_version.tar.gz${CEND}] found"
    echo "Press Ctrl+c to cancel or Press any key to continue..."
    char=`get_char`
    tar xzf nginx-$NEW_Nginx_version.tar.gz
    cd nginx-$NEW_Nginx_version
    make clean
    sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' auto/cc/gcc # close debug
    $nginx_install_dir/sbin/nginx -V &> $$
    nginx_configure_arguments=`cat $$ | grep 'configure arguments:' | awk -F: '{print $2}'`
    rm -rf $$
    ./configure $nginx_configure_arguments
    make -j ${THREAD}
    if [ -f "objs/nginx" ];then
        /bin/mv $nginx_install_dir/sbin/nginx $nginx_install_dir/sbin/nginx$(date +%m%d)
        /bin/cp objs/nginx $nginx_install_dir/sbin/nginx
        kill -USR2 `cat /var/run/nginx.pid`
        sleep 1
        kill -QUIT `cat /var/run/nginx.pid.oldbin`
        echo "You have ${CMSG}successfully${CEND} upgrade from ${CWARNING}$OLD_Nginx_version${CEND} to ${CWARNING}$NEW_Nginx_version${CEND}"
    else
        echo "${CFAILURE}Upgrade Nginx failed! ${CEND}"
    fi
    cd ..
fi
cd ..
}

Upgrade_Tengine() {
cd $oneinstack_dir/src
[ ! -e "$tengine_install_dir/sbin/nginx" ] && echo "${CWARNING}Tengine is not installed on your system! ${CEND}" && exit 1
OLD_Tengine_version_tmp=`$tengine_install_dir/sbin/nginx -v 2>&1`
OLD_Tengine_version="`echo ${OLD_Tengine_version_tmp#*/} | awk '{print $1}'`"
echo
echo "Current Tengine Version: ${CMSG}$OLD_Tengine_version${CEND}"
while :; do echo
    read -p "Please input upgrade Tengine Version(example: 2.1.15): " NEW_Tengine_version
    if [ "$NEW_Tengine_version" != "$OLD_Tengine_version" ];then
        [ ! -e "tengine-$NEW_Tengine_version.tar.gz" ] && wget --no-check-certificate -c http://tengine.taobao.org/download/tengine-$NEW_Tengine_version.tar.gz > /dev/null 2>&1
        if [ -e "tengine-$NEW_Tengine_version.tar.gz" ];then
            src_url=https://www.openssl.org/source/openssl-$openssl_version.tar.gz && Download_src
            src_url=http://mirrors.linuxeye.com/oneinstack/src/pcre-$pcre_version.tar.gz && Download_src
            tar xzf openssl-$openssl_version.tar.gz
            tar xzf pcre-$pcre_version.tar.gz
            echo "Download [${CMSG}tengine-$NEW_Tengine_version.tar.gz${CEND}] successfully! "
            break
        else
            echo "${CWARNING}Tengine version does not exist! ${CEND}"
        fi
    else
        echo "${CWARNING}input error! Upgrade Tengine version is the same as the old version${CEND}"
    fi
done

if [ -e "tengine-$NEW_Tengine_version.tar.gz" ];then
    echo "[${CMSG}tengine-$NEW_Tengine_version.tar.gz${CEND}] found"
    echo "Press Ctrl+c to cancel or Press any key to continue..."
    char=`get_char`
    tar xzf tengine-$NEW_Tengine_version.tar.gz
    cd tengine-$NEW_Tengine_version
    make clean
    sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' auto/cc/gcc # close debug
    $tengine_install_dir/sbin/nginx -V &> $$
    tengine_configure_arguments=`cat $$ | grep 'configure arguments:' | awk -F: '{print $2}'`
    rm -rf $$
    ./configure $tengine_configure_arguments
    make -j ${THREAD}
    if [ -f "objs/nginx" ];then
        /bin/mv $tengine_install_dir/sbin/nginx $tengine_install_dir/sbin/nginx$(date +%m%d)
        /bin/mv $tengine_install_dir/sbin/dso_tool $tengine_install_dir/sbin/dso_tool$(date +%m%d)
        /bin/mv $tengine_install_dir/modules $tengine_install_dir/modules$(date +%m%d)
        /bin/cp objs/nginx $tengine_install_dir/sbin/nginx
        /bin/cp objs/dso_tool $tengine_install_dir/sbin/dso_tool
        chmod +x $tengine_install_dir/sbin/*
        make install
        kill -USR2 `cat /var/run/nginx.pid`
        sleep 1
        kill -QUIT `cat /var/run/nginx.pid.oldbin`
        echo "You have ${CMSG}successfully${CEND} upgrade from ${CWARNING}$OLD_Tengine_version${CEND} to ${CWARNING}$NEW_Tengine_version${CEND}"
    else
        echo "${CFAILURE}Upgrade Tengine failed! ${CEND}"
    fi
    cd ..
fi
cd ..
}

Upgrade_OpenResty() {
cd $oneinstack_dir/src
[ ! -e "$openresty_install_dir/nginx/sbin/nginx" ] && echo "${CWARNING}OpenResty is not installed on your system! ${CEND}" && exit 1
OLD_OpenResty_version_tmp=`$openresty_install_dir/nginx/sbin/nginx -v 2>&1`
OLD_OpenResty_version="`echo ${OLD_OpenResty_version_tmp#*/} | awk '{print $1}'`"
echo
echo "Current OpenResty Version: ${CMSG}$OLD_OpenResty_version${CEND}"
while :; do echo
    read -p "Please input upgrade OpenResty Version(example: 1.9.7.19): " NEW_OpenResty_version
    if [ "$NEW_OpenResty_version" != "$OLD_OpenResty_version" ];then
        [ ! -e "openresty-$NEW_OpenResty_version.tar.gz" ] && wget --no-check-certificate -c https://openresty.org/download/openresty-$NEW_OpenResty_version.tar.gz > /dev/null 2>&1
        if [ -e "openresty-$NEW_OpenResty_version.tar.gz" ];then
            src_url=https://www.openssl.org/source/openssl-$openssl_version.tar.gz && Download_src
            src_url=http://mirrors.linuxeye.com/oneinstack/src/pcre-$pcre_version.tar.gz && Download_src
            tar xzf openssl-$openssl_version.tar.gz
            tar xzf pcre-$pcre_version.tar.gz
            echo "Download [${CMSG}openresty-$NEW_OpenResty_version.tar.gz${CEND}] successfully! "
            break
        else
            echo "${CWARNING}OpenResty version does not exist! ${CEND}"
        fi
    else
        echo "${CWARNING}input error! Upgrade OpenResty version is the same as the old version${CEND}"
    fi
done

if [ -e "openresty-$NEW_OpenResty_version.tar.gz" ];then
    echo "[${CMSG}openresty-$NEW_OpenResty_version.tar.gz${CEND}] found"
    echo "Press Ctrl+c to cancel or Press any key to continue..."
    char=`get_char`
    tar xzf openresty-$NEW_OpenResty_version.tar.gz
    cd openresty-$NEW_OpenResty_version
    make clean
    openresty_version_tmp=${NEW_OpenResty_version%.*}
    sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' bundle/nginx-$openresty_version_tmp/auto/cc/gcc # close debug
    $openresty_install_dir/nginx/sbin/nginx -V &> $$
    openresty_configure_arguments=`cat $$ | grep 'configure arguments:' | awk -F: '{print $2}'`
    rm -rf $$
    [ -n "`echo $openresty_configure_arguments | grep jemalloc`"] && malloc_module="--with-ld-opt='-ljemalloc'"
    [ -n "`echo $openresty_configure_arguments | grep perftools`" ] && malloc_module='--with-google_perftools_module'
    ./configure --prefix=$openresty_install_dir --user=$run_user --group=$run_user --with-http_stub_status_module --with-http_v2_module --with-http_ssl_module --with-ipv6 --with-http_gzip_static_module --with-http_realip_module --with-http_flv_module --with-openssl=../openssl-$openssl_version --with-pcre=../pcre-$pcre_version --with-pcre-jit $malloc_module
    make -j ${THREAD}
    if [ -f "build/nginx-$openresty_version_tmp/objs/nginx" ];then
        /bin/mv $openresty_install_dir/nginx/sbin/nginx $openresty_install_dir/nginx/sbin/nginx$(date +%m%d)
        make install
        kill -USR2 `cat /var/run/nginx.pid`
        sleep 1
        kill -QUIT `cat /var/run/nginx.pid.oldbin`
        echo "You have ${CMSG}successfully${CEND} upgrade from ${CWARNING}$OLD_OpenResty_version${CEND} to ${CWARNING}$NEW_OpenResty_version${CEND}"
    else
        echo "${CFAILURE}Upgrade OpenResty failed! ${CEND}"
    fi
    cd ..
fi
cd ..
}
