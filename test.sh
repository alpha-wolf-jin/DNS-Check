#!/bin/sh

# 
# ./DNS-Check.sh ./server_list 
#
# cat ./server_list 
# helper.example.com	192.168.9.5


input_file=$1

IFS=','

while read -u12 target_server host remote_ip
do
	echo "$target_server  $host  $remote_ip"
done 12< ${input_file}
