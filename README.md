# DNS-Check
The script is to verify the forward and reverse DNS on specified host.

The script have 2 paramter

```
[root@helper pre-check]# ./DNS-Check.sh server_list dns-check-list
```

1st paramter is the file including the specified host list. 

Sample input file:
```
[root@helper pre-check]# cat server_list 
192.168.122.29
192.168.122.11
```

2nd parameter is the file including the hostname and IP in each line. This script uses `dig` commnad to verify the DNS forward and reserver resolving.

Sample input file:
```
[root@helper pre-check]# cat dns-check-list 
api-int.ocp4.example.com	192.168.9.5
graphic.example.com		192.168.9.201
helper.example.com		192.168.9.5
```

**Prerequisite**

- script has passwordless ssh access to the server in file server_list.



