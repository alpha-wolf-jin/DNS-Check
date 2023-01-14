#!/bin/sh

# 
# ./DNS-Check.sh ./server_list 
#
# cat ./server_list 
# helper.example.com	192.168.9.5

server_list=$1
dns_list=$2

ColorR='\033[0;31m' # red (fail)
ColorB='\033[0;34m' # blue (info)
ColorC='\033[0;36m' # cyan (header)
ColorY='\033[0;33m' # yellow/orange (warning)
ColorG='\033[0;32m' # green (success)
ColorN='\033[0m' # Normal (reset)


dns_record_check () {
 
  local target_server=$1
  local dns_server=$2
  local dns_IP=$3
  local forward_dns=false
  local reverse_dns=false
  local ssh_cmd=''

  mkfifo /tmp/mypipe 

  printf "Forward DNS ${dns_server}\t===>\t${dns_IP}\n"
  ssh -o StrictHostKeyChecking=no $target_server "dig $dns_server +noall +answer" | awk '{print $NF}' > /tmp/mypipe &

  while IFS= read return_ip
  do
    if [ ${return_ip} == $dns_IP ]
      then
        export forward_dns=true
    fi
  done < /tmp/mypipe

  #rm -f /tmp/mypipe

  if ${forward_dns}
    then
      printf "Result: ${ColorG}Success\n${ColorN}"
    else
      printf "Result: ${ColorR}Failure\n${ColorN}"
  fi

  #mkfifo /tmp/mypipe 

  printf "Reverse DNS ${dns_IP}\t===>\t${dns_server}\n"
  ssh -o StrictHostKeyChecking=no $1 "dig -x $3 +noall +answer" | awk '{print $NF}' > /tmp/mypipe &

  while IFS= read return_host
  do
    if [ ${return_host} == $2. ]
      then
        reverse_dns=true
    fi
  done < /tmp/mypipe

  rm -f /tmp/mypipe

  if ${reverse_dns}
    then
      printf "Result: ${ColorG}Success\n${ColorN}"
    else
      printf "Result: ${ColorR}Failure\n${ColorN}"
  fi

  echo
}

remote_dns_record_check () {
  
  local target_host=$1

  while read -u10 dns_host dns_ip
  do
    if [ ! -z ${dns_host} ] && [ ! -z ${dns_ip} ]
      then
        #echo "dns_record_check ${target_host} ${dns_host} ${dns_ip}"

        dns_record_check ${target_host} ${dns_host} ${dns_ip}
      else
	printf "${ColorR}Please ensure input data in file (${dns_list}) have both hostname(${dns_host}) and ip(${dns_ip}).\n${ColorN}" 
    fi
  done 10< ${dns_list}
}

# Main

main () {

  while read -u12 target_host
  do
    if [ ! -z ${target_host} ]
      then
        remote_ssh="ssh -o StrictHostKeyChecking=no $target_host date >/dev/null"
        ${remote_ssh}
        if [ $? -eq 0 ] 
          then
            printf "${ColorC}\nDNS Verification on ${target_host} >>>>>>\n\n${ColorN}" 
            remote_dns_record_check ${target_host}
  	else
            printf "${ColorR}Failed to execute \"${remote_ssh}\"\n${ColorN}" 
            printf "${ColorR}Please ensure passwordless ssh remote access from local server to ${target_host}.\n${ColorN}" 
        fi
    fi
  done 12< ${server_list}
}

main
