#!/bin/bash
set -x

# USE_CACHE is passed for devtest.sh, -c option
USE_CACHE=

SCRIPT_NAME=$(basename $0)
TEMP=`getopt -o c -n $SCRIPT_NAME -- "$@"`
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -c) USE_CACHE="-c" ; shift 1;;
        --) shift ; break ;; 
        *) echo "Error: unsupported option $1." ; exit 1 ;;
    esac
done 

# update localhost http_proxy
# just ease the switch betewwn home and office env
if [ -n "$(ifconfig |grep 172.21.118.158)" ]; then
  echo 'Acquire::http::Proxy "http://172.21.118.158:3128";' > 60proxy 
  export http_proxy="http://172.21.118.158:3128"
else
  echo 'Acquire::http::Proxy "http://192.168.1.100:3128";'  > 60proxy 
  export http_proxy="http://192.168.1.100:3128"
fi
sudo cp -f 60proxy /etc/apt/apt.conf.d/60apt-proxy 
sudo service squid3 restart


# set env variables for tripleo
export PATH=/home/kui/tripleo/tripleo-incubator/scripts:$PATH
export TRIPLEO_ROOT=/home/kui/tripleo
export DIB_APT_SOURCES=/etc/apt/sources.list
export ELEMENTS_PATH=$TRIPLEO_ROOT/tripleo-image-elements/elements
export UNDERCLOUD_DIB_EXTRA_ARGS="nova-ironic"
export NODE_DIST="ubuntu apt-sources pip-cache"

# copy the ironic-element
# substitude the ironicclient with the latest repo
if [ -z "$USE_CACHE" ]; then
  install-dependencies
  pull-tools
  cp -arf $TRIPLEO_ROOT/ironic-element/* $TRIPLEO_ROOT/tripleo-image-elements/ 
  cp -arf $TRIPLEO_ROOT/python-ironicclient/ironicclient $TRIPLEO_ROOT/tripleo-incubator/openstack-tools/lib/python2.7/site-packages/ironicclient
fi

lognum=`date +%d%H%M`
start_seconds=`date +%s.%N`
devtest.sh $USE_CACHE --trash-my-machine  2>&1  | tee devtest_all_$lognum.log
stop_seconds=`date +%s.%N`

duration=$(python -c "print $stop_seconds - $start_seconds")
LC_NUMERIC=C printf "Duration: %10.3f\n"  $duration
