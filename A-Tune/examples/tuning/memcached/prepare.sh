#!/bin/sh
# Copyright (c) lingff(ling@stu.pku.edu.cn),
# School of Software & Microelectronics, Peking University.
#
# A-Tune is licensed under the Mulan PSL v2.
# You can use this software according to the terms and conditions of the Mulan PSL v2.
# You may obtain a copy of Mulan PSL v2 at:
#     http://license.coscl.org.cn/MulanPSL2
# THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR
# PURPOSE.
# See the Mulan PSL v2 for more details.
#
# Create: 2021-08-08
path=$(
  cd "$(dirname "$0")"
  pwd
)

local_memcached_ip=$(ifconfig  | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}')
echo "local memcached IP:" $local_memcached_ip

net_card_name=$(cat /proc/net/dev | awk '{i++; if(i>2){print $1}}'| grep -v lo| sed 's/^[\t]*//g' | sed 's/[:]*$//g')
echo "network card name:" $net_card_name

echo "install memcached..."
yum install libevent libevent-devel -y
yum install memcached -y
yum list telnet*
yum install telnet-server -y
yum install telnet.*

read -t 20 -p "please input an another host IP to install memaslap(SSH required):" memaslap_ip
echo -e "\n"
echo "memaslap host ip:" $memaslap_ip

echo "copy install_memaslap.sh to : " $memaslap_ip:
scp install_memaslap.sh root@$memaslap_ip:/root/

echo "install memaslap on :" $memaslap_ip
ssh -t root@$memaslap_ip "sh install_memaslap.sh"

echo "update the client and server yaml files， and assign values to variables..."
sed -i "s#sh .*/memcached_memaslap_benchmark.sh#sh $path/memcached_memaslap_benchmark.sh#g" $path/memcached_memaslap_client.yaml
sed -i "s#cat .*/memaslap_benchmark.log#cat $path/memaslap_benchmark.log#g" $path/memcached_memaslap_client.yaml
sed -i "s#local_memcached_ip=.*#local_memcached_ip=$local_memcached_ip#g" $path/memcached_memaslap_benchmark.sh
sed -i "s#memaslap_ip=.*#memaslap_ip=$memaslap_ip#g" $path/memcached_memaslap_benchmark.sh
sed -i "s#-l.*-f#-l $local_memcached_ip -f#g" $path/memcached
sed -i "s#enp1s0#$net_card_name#g" $path/memcached_memaslap_server.yaml

echo "initializing memcached..."
rm -f /etc/sysconfig/memcached
cp memcached /etc/sysconfig

echo "start memcached..."
systemctl restart memcached.service
echo "initialized memcached..."

echo "copy the server yaml file to /etc/atuned/tuning/"
cp $path/memcached_memaslap_server.yaml /etc/atuned/tuning/
