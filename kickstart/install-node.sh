#!/bin/bash


#set -x 
usage() {
    echo "Usage: $0 -u user -s server_name -u user -i ip address  -m netmask  -g gateway  -n nameserver -p pool -x memory -y size -z cpus [ -h help ]" 1>&2  
    exit 1
}

if ( ! getopts ":s:i:m:g:n:x:y:z:h:u:p:" opt); then
    usage
fi

while getopts ":s:i:m:g:n:x:y:z:h:u:p:" opt; do
  case $opt in
    s)
      SERVER_NAME=$OPTARG
      ;;
    i)
      IP_ADDR=$OPTARG
      ;;
    m)
      NETMASK=$OPTARG
      ;;
    g)
      GATEWAY=$OPTARG
      ;;
    n)
      NAMESERVER=$OPTARG
      ;;
    p)
      POOL=$OPTARG
      ;;
    u)
      USER=$OPTARG
      ;;
    x)
      MEMORY=$OPTARG
      ;;
    y)
      SIZE=$OPTARG
      ;;
    z)
      CPUS=$OPTARG
      ;;
      
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
    h)
      usage
      ;;
  esac
done

cd "$(dirname "$0")"
output=$(./ks-user-config.py)
rc=$?
if [ $rc -ne 0 ]
then
   echo "exiting: $output"
   exit $rc
fi
PASSWORD=$output
echo "User is: $USER"
echo "Encrypted password is: $PASSWORD"
KICKSTART_FILE=generated/ks-openshift-$SERVER_NAME.cfg

mkdir -p generated
cp ks-openshift.cfg $KICKSTART_FILE
sed -i 's/IP_ADDR/'$IP_ADDR'/g' $KICKSTART_FILE
sed -i 's/NETMASK/'$NETMASK'/g' $KICKSTART_FILE
sed -i 's/GATEWAY/'$GATEWAY'/g' $KICKSTART_FILE
sed -i 's/NAMESERVER/'$NAMESERVER'/g' $KICKSTART_FILE
sed -i 's/USER/'$USER'/g' $KICKSTART_FILE
sed -i 's|PASSWORD|'$PASSWORD'|g' $KICKSTART_FILE

KICKSTART_FULL_PATH=`realpath $KICKSTART_FILE`
echo "kickstart full path: $KICKSTART_FULL_PATH"


virt-install \
    --name $SERVER_NAME \
    --memory $MEMORY \
    --cpu Broadwell,require=vmx \
    --vcpus $CPUS \
    --disk pool=$POOL,size=$SIZE\
    --location /home/qemu/rhel-server-7.4-x86_64-dvd.iso \
    --os-variant rhel7 \
    --graphics none \
    --network bridge=br-ex \
    --initrd-inject $KICKSTART_FULL_PATH \
    --console pty,target_type=serial \
    --extra-args 'ks=file:/ks-openshift-'"$SERVER_NAME.cfg"' console=ttyS0,115200n8 serial'
