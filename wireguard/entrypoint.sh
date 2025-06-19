#!/bin/sh

set -e

cleanup() {
  echo "Caught SIGTERM, shutting down WireGuard..."
  ip link delete wg0 || true
  exit 0
}

trap cleanup TERM INT

SERVER_PORT=${SERVER_PORT:-51820}
SERVER_HOST=${SERVER_HOST:-127.0.0.1}
PEER_COUNT=${PEER_COUNT:-1}
PEER_DNS=${PEER_DNS:-1.1.1.1,8.8.8.8}

generate_config() {
  mkdir -p /config/peers

  count=$1
  SERVER_PRIVATE_KEY=$(wg genkey)
  SERVER_PUBLIC_KEY=$(echo "$SERVER_PRIVATE_KEY" | wg pubkey)
  SERVER_ENDPOINT="$SERVER_HOST:$SERVER_PORT"

  cat > /config/wg0.conf <<EOF
[Interface]
PrivateKey = $SERVER_PRIVATE_KEY
ListenPort = $SERVER_PORT
EOF

  i=0
  while [ "$i" -lt "$count" ]; do
    PEER_PRIVATE_KEY=$(wg genkey)
    PEER_PUBLIC_KEY=$(echo "$PEER_PRIVATE_KEY" | wg pubkey)
    PEER_ADDRESS="10.0.0.$((i+2))/24"

    cat >> /config/wg0.conf <<EOF

[Peer]
PublicKey = $PEER_PUBLIC_KEY
AllowedIPs = 10.0.0.$((i+2))/32
EOF

    cat > /config/peers/peer_$i.conf <<EOF
[Interface]
PrivateKey = $PEER_PRIVATE_KEY
Address = $PEER_ADDRESS
$(echo "$PEER_DNS" | tr ',' '
' | sed 's/^/DNS = /' | paste -sd '
' -)

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $SERVER_ENDPOINT
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

    i=$((i+1))
  done
}

[ ! -f /config/wg0.conf ] && generate_config "$PEER_COUNT"

ip link add wg0 type wireguard
ip addr add 10.0.0.1/24 dev wg0
ip link set up dev wg0
wg setconf wg0 /config/wg0.conf

ip route del default
ip route add default via 172.29.0.4

iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o eth0 -j MASQUERADE
iptables -A FORWARD -i wg0 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o wg0 -m state --state RELATED,ESTABLISHED -j ACCEPT

tail -f /dev/null &
wait $!
