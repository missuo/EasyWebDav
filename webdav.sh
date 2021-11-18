#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#================================================================
#	System Required: CentOS 6/7/8,Debian 8/9/10,Ubuntu 16/18/20
#	Kernel Required: None
#	Description: Quick and easy to set up WebDav server on Linux Server
#	Version: 1.0
#	Author: Vincent Young
# 	Telegram: https://t.me/missuo
#	Github: https://github.com/missuo/CloudflareWarp
#	Latest Update: Nov 18, 2021
#=================================================================

# 定义一些颜色
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# 确保本脚本在ROOT下运行
[[ $EUID -ne 0 ]] && echo -e "[${red}错误${plain}]请以ROOT运行本脚本！" && exit 1

# 检查系统信息
check_sys(){
	echo "现在开始检查你的系统是否支持..."
	# 判断是什么Linux系统
	if [[ -f /etc/redhat-release ]]; then
		release="Centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="Debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="Ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="Centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="Debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="Ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="Centos"
    fi

	# 根据系统类型确定
	if [ $release = "Centos" ]
	then
		sysctl_dir="/usr/lib/systemd/system/"
	elif [ $release = "Debian" ]
	then
		sysctl_dir="/etc/systemd/system/"
	elif [ $release = "Ubuntu" ]
	then
		sysctl_dir="/lib/systemd/system/"
	else
		echo -e "[${red}错误${plain}]不支持当前系统"
		exit 1
	fi
}
check_sys

config_webdav(){
    wget -N --no-check-certificate -O /etc/webdav.yaml https://raw.githubusercontent.com/missuo/EasyWebDav/main/webdav.yaml
    echo "现在开始配置 WebDav 的参数..."
    echo ""
    read -p "请输入监听的端口:" listen_port
	[ -z "${listen_port}" ]
	echo ""
    read -p "请输入WebDav访问账号:" username
    [ -z "${username}" ]
    echo ""
    read -p "请输入WebDav访问密码:" username
    [ -z "${username}" ]
    echo ""
    read -p "请输入WebDav的路径(默认/root):" scope
    [ -z "${scope}" ]
    echo ""
    echo "正在尝试写入配置文件..."
    sed -i "s/port:.*/port: ${listen_port}/g" /etc/webdav.yaml
    sed -i "s/username:.*/username: ${username}/g" /etc/webdav.yaml
    sed -i "s/password:.*/password: ${password}/g" /etc/webdav.yaml
    sed -i "s/scope:.*/scope: ${scope}/g" /etc/webdav.yaml
    echo "配置文件写入完成！"
    echo ""
}


deploy_webdav(){
        if [ ! -f "/usr/bin/webdav" ]; then
            echo "现在开始安装 WebDav..."
            echo ""
            last_version=$(curl -Ls "https://api.github.com/repos/hacdias/webdav/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
            if [[ ! -n "$last_version" ]]; then
                echo -e "${red}检测 WebDav 版本失败，可能是超出 Github API 限制，请稍后再试。"
                exit 1
            fi
            echo -e "检测到 WebDav 最新版本：${last_version}，开始安装"
            wget -N --no-check-certificate -O /usr/bin/linux-amd64-webdav.tar.gz https://github.com/hacdias/webdav/releases/download/${last_version}/linux-amd64-webdav.tar.gz
            tar -xzf /usr/bin/linux-amd64-webdav.tar.gz -C /usr/bin/
            rm -rf /usr/bin/linux-amd64-webdav.tar.gz
            chmod +x /usr/bin/webdav
            echo "WebDav 安装完成！"
            echo ""
            echo "开始启动 WebDav 并设置为开机自启..."
            echo ""
            wget -N --no-check-certificate -O ${sysctl_dir}/webdav.service https://raw.githubusercontent.com/missuo/EasyWebDav/main/webdav.service
            systemctl enable webdav.service
            systemctl start webdav.service
            public_ip=$(curl -s https://ipinfo.io/ip)
            echo "------------------------------------------------"
            echo "WebDav 监听端口: ${listen_port}"
            echo "WebDav 访问账号: ${username}"
            echo "WebDav 访问密码: ${password}"
            echo "WebDav 访问地址: ${public_ip}:${listen_port}"
            echo "------------------------------------------------"
            echo "WebDav 启动成功！如果要开启域名访问，请自行设置反向代理！"

        else
            echo "你已经安装 WebDav 服务！"
        fi

}

config_webdav
deploy_webdav
