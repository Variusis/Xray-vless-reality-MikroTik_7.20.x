#!/bin/sh
echo "Starting setup container please wait"
sleep 1

NET_IFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -vE 'lo|tun' | head -n1 | cut -d'@' -f1)
CONTAINER_IP=$(ip -4 addr show $NET_IFACE | grep inet | awk '{ print $2 }' | cut -d/ -f1)
sleep 15
CONTAINER_BRIDGE_IP=$(arp -a | grep ether | awk -F'(' '{print $2}' | cut -d')' -f1)
sleep 15

HOST_STRING=$(sed -n '/xray-vless/=' /etc/hosts)
sed -r -i ""$HOST_STRING"c\"$CONTAINER_IP" xray-vless" /etc/hosts

SERVER_ADDRESS=$(echo "$FULL_STRING" | sed "s/^.@//g" | sed "s/?type. / / g " | s e d " s / : . ∗ //g")
SERVER_IP_ADDRESS=$(ping -c 1 $SERVER_ADDRESS | awk -F'[()]' '{print $2}')

if [ -z "$SERVER_IP_ADDRESS" ]; then
echo "Failed to obtain an IP address for FQDN $SERVER_ADDRESS"
echo "Please configure DNS on Mikrotik (add rule in IP - Firewall - Filter Rules):"
echo "Chain: input Dst Address: <docker_bridge_address> Protocol: udp Dst. Port: 53 Action: accept"
exit 1
fi
ip tuntap del mode tun dev tun0
ip tuntap add mode tun dev tun0
ip addr add 172.31.200.10/30 dev tun0
ip link set dev tun0 up
ip route del default via $CONTAINER_BRIDGE_IP
ip route add default via 172.31.200.10
ip route add $SERVER_IP_ADDRESS/32 via $CONTAINER_BRIDGE_IP

rm -f /etc/resolv.conf

tee -a /etc/resolv.conf <<< "nameserver "$CONTAINER_BRIDGE_IP""

NETWORK=$(echo "$FULL_STRING" | sed "s/^.type=//g" | sed "s/&encryption.$//g")
if [ "$NETWORK" == "tcp" ]; then
/bin/sh /opt/tcpraw.sh
fi
if [ "$NETWORK" == "xhttp" ]; then
/bin/sh /opt/xhttp.sh
fi

echo "Xray and tun2socks preparing for launch"
rm -rf /tmp/xray/ && mkdir /tmp/xray/
7z x /opt/xray/xray.7z -o/tmp/xray/ -y
chmod 755 /tmp/xray/xray
rm -rf /tmp/tun2socks/ && mkdir /tmp/tun2socks/
7z x /opt/tun2socks/tun2socks.7z -o/tmp/tun2socks/ -y
chmod 755 /tmp/tun2socks/tun2socks
echo "Start Xray core"
/tmp/xray/xray run -config /opt/xray/config/config.json &
#pkill xray
echo "Start tun2socks"
#/tmp/tun2socks/tun2socks -loglevel silent -tcp-sndbuf 3m -tcp-rcvbuf 3m -device tun0 -proxy socks5://127.0.0.1:10800 -interface eth0 &
/tmp/tun2socks/tun2socks -loglevel silent -tcp-sndbuf 3m -tcp-rcvbuf 3m -device tun0 -proxy socks5://127.0.0.1:10800 -interface $NET_IFACE &
#pkill tun2socks
echo "Container customization is complete"`
