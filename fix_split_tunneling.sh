#!/bin/bash

rootcheck () {
  if [ $(id -u) != "0" ]
    then
      echo "We need sudo permissions to run this script"
      exit $?
  fi
}

rootcheck "$@"

default_line=$(netstat -rn | grep default | grep en | tail -n1)
gateway=$(echo $default_line | awk '{print $2}')
interface=$(echo $default_line | awk '{print $6}')

echo "Fixing $interface with gateway $gateway"

route delete default
route delete -ifscope $interface default
route add -ifscope $interface default $gateway
route add -net 0.0.0.0 -interface $gateway

#Adding remote vpn network
route -nv add -net 10.218 -interface ppp0

#Setting Public DNS
scutil <<EOF
d.init
d.add ServerAddresses 80.58.61.254 80.58.61.250
set State:/Network/Service/forticlientsslvpn/DNS
quit
EOF

