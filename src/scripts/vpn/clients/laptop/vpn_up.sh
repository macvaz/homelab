#! /bin/bash

set -e

echo "****************"
echo "Configuring VPN"
echo "****************"
echo

BASEDIR=$(dirname "$0")
source "$BASEDIR/.env"
source "$BASEDIR/vpn_constants"

echo "Current SSID   ": $wifi_connection
echo "Trusted SSID   ": $trusted_connection
echo "Current DNS    ": $wifi_dns
echo "At home        ": $at_home
echo "VPN stablished ": $vpn_stablished
echo

connect_vpn() {
  echo "Starting wireguard VPN tunnel"
  sudo systemctl start wg-quick@wg0.service

  echo "Pointing DNS to pihole"
  nmcli conn modify $trusted_connection ipv4.ignore-auto-dns yes
  nmcli conn modify $trusted_connection ipv4.dns "$PIHOLE $PIHOLE2"

  echo "Restarting networking"
  sudo systemctl restart NetworkManager
}

if [ "$wifi_dns" == "$PIHOLE" ] && [ "$at_home" == "no" ] && [ "$vpn_stablished" == "no" ]; then
  # Under these conditions, stablishing a VPN tunnel can be tricky due to DNS misconfiguration
  # vpn_down.sh script deals with this DNS configuration
  $BASEDIR/vpn_down.sh

  echo

  connect_vpn
  exit 0
fi

if [ "$wifi_dns" == "$PIHOLE" ] && [ "$at_home" == "no" ] && [ "$vpn_stablished" == "yes" ]; then
    echo "Away from home but VPN tunnel is already stablished"
    echo "Nothing to do"
    exit 0
fi

if [ "$at_home" == "no" ]; then
  connect_vpn
  exit 0
fi

if [ "$at_home" == "yes" ] ; then
    echo "Using home network. No VPN tunnel required"
    echo "Nothing to do"
    exit 0
fi
