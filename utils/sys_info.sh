#!/bin/bash

USERNAME="testing"
PASSWD="open1234asd"

distro=""
#sys_info=$(uname -a)
sys_info=$(cat /etc/os-release | grep PRETTY_NAME)

if [ "$(echo $sys_info |grep -E 'UBUNTU|Ubuntu|ubuntu')"x != ""x ]; then
    distro="ubuntu"
elif [ "$(echo $sys_info |grep -E 'cent|CentOS|centos')"x != ""x ]; then
    distro="centos"
elif [ "$(echo $sys_info |grep -E 'fed|Fedora|fedora')"x != ""x ]; then
    distro="fedora"
elif [ "$(echo $sys_info |grep -E 'DEB|Deb|deb')"x != ""x ]; then
    distro="debian"
elif [ "$(echo $sys_info |grep -E 'OPENSUSE|OpenSuse|opensuse')"x != ""x ]; then
    distro="opensuse"
else
    distro="ubuntu"
fi

#local_ip=$(ip addr show `ip route | grep "default" | awk '{print $NF}'`| grep -o "inet [0-9\.]*" | cut -d" " -f 2)
#modify by liucaili 20171028
#local_ip=$(ip addr show `ip route | grep "default" | awk '{print $5}'`| grep -o "inet [0-9\.]*" | cut -d" " -f 2)

#tanliqing modify 
local_ip=`ip addr | grep -A2 "state UP" | tail -1 | awk {'print $2'} | cut -d / -f 1`
if [ ${local_ip}x = ""x ]; then
    #local_ip=$(ifconfig `route -n | grep "^0"|awk '{print $NF}'`|grep -o "addr inet:[0-9\.]*"|cut -d':' -f 2)
    local_ip=$(ifconfig `route -n | grep "^0"|awk '{print $5}'`|grep -o "addr inet:[0-9\.]*"|cut -d':' -f 2)
fi

start_service='systemctl start'
stop_service='systemctl stop'
reload_service='systemctl reload'
restart_service='systemctl restart'
enable_service='systemctl enable'
disable_service='systemctl disable'
status_service='systemctl status'

case $distro in
    "ubuntu" | "debian" )
        update_commands='apt-get update -y'
        install_commands='apt-get install -y'
        start_service=""
        reload_service=""
        restart_service=""
        status_service=""
        ;;
    "opensuse" )
        update_commands='zypper -n update'
        install_commands='zypper -n install'
        ;;
    "centos" )
        update_commands='yum update -y'
        install_commands='yum install -y'
        ;;
    "fedora" )
        update_commands='dnf update -y'
        install_commands='dnf install -y'
        ;;
esac

# 临时执行
case $distro in 
    centos)
        sed -i "s/5.1/5.0/g"  /etc/yum.repos.d/estuary.repo 
        yum clean all 
        ;;
    ubuntu)
        sed -i "s/5.1/5.0/g" /etc/apt/sources.list.d/estuary.list 
        apt-get update 
        ;;
    *)
        ;;
esac


red='\e[0;41m' # 红色  
RED='\e[1;31m'
green='\e[0;32m' # 绿色  
GREEN='\e[1;32m'
yellow='\e[5;43m' # 黄色  
YELLOW='\e[1;33m'
blue='\e[0;34m' # 蓝色  
BLUE='\e[1;34m'
purple='\e[0;35m' # 紫色  
PURPLE='\e[1;35m'
cyan='\e[4;36m' # 蓝绿色  
CYAN='\e[1;36m'
WHITE='\e[1;37m' # 白色
 
NC='\e[0m' # 没有颜色

print_info()
{

    if [ $1 -ne 0 ]; then
        result='fail'
        cor=$red 
    else
        result='pass'
        cor=$GREEN
    fi

    test_name=$2

    

    echo -e "${cor}the result of $test_name is $result${NC}"
    lava-test-case "$test_name" --result $result
}

download_file()
{
    url_address=$1
    let i=0
    while (( $i < 5 )); do
        wget $url_address
        if [ $? -eq 0 ]; then
            break;
        fi
        let "i++"
    done
}

Check_Version()
{
	deps_name=$1
	version=$2
	ver_info=$(yum info $deps_name | grep Version | awk '{print $3}')
	if [ $version == $ver_info ];then
		return 0
	else
		return 1
	fi
}


Check_Repo()
{
	deps_name=$1
	repo=$2
	repo_info=$(yum info $deps_name | grep Repo | awk '{print $3}')
	if [ $repo == $repo_info ];then
		return 0
	else
		return 1
	fi
}


# 用法：source本文件，执行本方法，就可以正常使用打印debug调试信息
# 1、如果系统中有lava-test-case命令，那么就不会打印信息，反之就会有打印调试信息
# 2、如果设置了DEBUG环境变量，那么就一定会打印调试信息
function outDebugInfo(){

    false 
    if test $DEBUG;then
        true
    else
        which lava-test-case > /dev/null 2>&1
        if test $? -ne 0;then 
            true 
        fi 
    fi 

    if test $? -eq 0;then
        set -x 
        export PS4='+{$LINENO:${FUNCNAME[0]}} '

    fi 
}


