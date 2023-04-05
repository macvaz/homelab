#! /bin/bash

wifi_connection=$(nmcli device show wlo1 | grep GENERAL.CONNECTION | tr -s ' ' | cut -d' ' -f2)
wifi_dns=$(nmcli device show wlo1 | grep IP4.DNS | tr -s ' ' | cut -d' ' -f2 | head -n 1)

# Bash functions doesn't return values
# The best workaround for simple scripting is to echo the intended return value and capture with a command substitution
# https://www.gnu.org/software/bash/manual/html_node/Command-Substitution.html
is_trusted_connection() {
  for trusted_network in "${TRUSTED_NETWORKS[@]}"; do
    if [ "$trusted_network" == "$1" ]; then
      echo "$trusted_network"
      return 0
    fi
  done
  echo "Untrusted network found: $wifi_connection"
  exit 1
}

is_at_home() {
  at_home=no
  if [ "$wifi_connection" == "$HOME_WIFI" ]; then
    at_home=yes
  fi
  echo "$at_home"
}

is_vpn_stablished() {
  found_wireguard=$(ip a | grep wg0 |  head -n 1 | wc -l)
  vpn_stablished=no
  if [ "$found_wireguard" == "1" ]; then
    vpn_stablished=yes
  fi
  echo "$vpn_stablished"
}


at_home=$(is_at_home)
vpn_stablished=$(is_vpn_stablished)
trusted_connection=$(is_trusted_connection "$wifi_connection")

export PIHOLE
export PIHOLE2
export wifi_dns
export at_home
export vpn_stablished
export trusted_connection
