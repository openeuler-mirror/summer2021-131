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
echo "initializing memcached..."
rm -f /etc/sysconfig/memcached
cp memcached /etc/sysconfig


echo "start memcached..."
systemctl restart memcached.service

echo "initialized memcached..."


echo "update the client and server yaml files"
sed -i "s#sh .*/memcached_memaslap_benchmark.sh#sh $path/memcached_memaslap_benchmark.sh#g" $path/memcached_memaslap_client.yaml
sed -i "s#cat .*/memaslap_benchmark.log#cat $path/memaslap_benchmark.log#g" $path/memcached_memaslap_client.yaml

echo "copy the server yaml file to /etc/atuned/tuning/"
cp $path/memcached_memaslap_server.yaml /etc/atuned/tuning/