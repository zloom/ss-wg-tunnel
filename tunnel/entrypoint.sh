#!/bin/bash
set -e

cleanup() {
  echo "Caught SIGTERM, stopping..."
  kill -TERM "$SS_PID" 2>/dev/null || true
  kill -TERM "$TUN_PID" 2>/dev/null || true
  wait "$SS_PID"
  wait "$TUN_PID"
  exit 0
}

trap cleanup SIGTERM

ip tuntap add mode tun tun0
ip addr add 10.0.0.2/24 dev tun0
ip link set dev tun0 up

GATEWAY=$(ip route | grep default | awk '{print $3}')
ip route add "$SS_SERVER" via "$GATEWAY"
ip rule add to "$SS_SERVER" lookup main priority 1000

iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
ip route del default
ip route add default dev tun0

go-shadowsocks2 -c "$SS_SERVER:$SS_PORT" -password "$SS_PASSWORD" -socks 127.0.0.1:1080 -u -verbose &
SS_PID=$!

tun2socks -device tun0 -proxy socks5://127.0.0.1:1080 -loglevel debug &
TUN_PID=$!

wait "$SS_PID"
wait "$TUN_PID"
