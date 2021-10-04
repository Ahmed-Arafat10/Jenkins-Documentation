// This script is used to save Private Key of container slave in your host {will be used in credential menu in jenkins server} 
// then copy file that containes IPAddress of container slave {will be used for host option while creating new node}
#! bin/bash
docker cp $1:/root/.ssh/id_rsa /home/arafat/Desktop/jenkinsproject/PrivateKey
docker inspect $1 | grep -i  ipaddress > IPAddress
