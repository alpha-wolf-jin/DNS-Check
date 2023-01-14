#!/bin/sh

# 
# ./DNS-Check.sh ./server_list 
#
# cat ./server_list 
# helper.example.com	192.168.9.5


dns_record_check () {
 
  local target_server=$1
  local dns_server=$2
  local dns_IP=$3
  local forward_dns=false
  local reverse_dns=false
  
  mkfifo /tmp/mypipe 

  ssh -o StrictHostKeyChecking=no $target_server "dig $dns_server +noall +answer" | awk '{print $NF}' > /tmp/mypipe &

  while IFS= read dns_ip
  do
    if [ ${dns_ip} == $dns_IP ]
      then
        export forward_dns=true
    fi
  done < /tmp/mypipe

  rm -f /tmp/mypipe

  if ${forward_dns}
    then
      echo "Success: Forward DNS works for host $dns_server on server $target_server"
    else
      echo "Fail   : Forward DNS fails for host $dns_server on server $target_server"
  fi

  mkfifo /tmp/mypipe 

  ssh -o StrictHostKeyChecking=no $1 "dig -x $3 +noall +answer" | awk '{print $NF}' > /tmp/mypipe &

  while IFS= read dns_host
  do
    if [ ${dns_host} == $2. ]
      then
        reverse_dns=true
    fi
  done < /tmp/mypipe

  rm -f /tmp/mypipe

  if ${reverse_dns}
    then
      echo "Success: Reverse DNS works for IP $dns_IP on server $target_server"
    else
      echo "Fail   : Reverse DNS fails for IP $dns_IP on server $target_server"
  fi

  echo
}

remote_dns_record_check () {
  
#  cat $1 |\
  while read -u10 target_host ip
  do
    if [ ! -z ${ip} ] && [ ! -z ${target_host} ]
      then
        dns_record_check $2 ${target_host} ${ip}
    fi
  done 10< $1
}

# Main
server_list=$1

#cat ${server_list} |\
while read -u12 host remote_ip
do
  if [ ! -z ${remote_ip} ] && [ ! -z ${host} ]
    then
      remote_dns_record_check ${server_list} ${remote_ip}
  fi
done 12< ${server_list}
