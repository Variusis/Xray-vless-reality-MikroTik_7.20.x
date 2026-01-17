#!/bin/sh

NETWORK=$(echo "$FULL_STRING" | sed "s/^.type=//g" | sed "s/&.$//g")
USER_ID=$(echo "$FULL_STRING" | sed "s/^.:////g" | sed "s/@.$//g")
SERVER_ADDRESS=$(echo "$FULL_STRING" | sed "s/^.@//g" | sed "s/?.$//g" | sed "s/:.$//g")
SERVER_PORT=$(echo "$FULL_STRING" | sed "s/^.@//g" | sed "s/?.$//g" | sed "s/^.://g")
ENCRYPTION=$(echo "$FULL_STRING" | sed "s/^.encryption=//g" | sed "s/&.$//g")
FINGERPRINT_FP=$(echo "$FULL_STRING" | sed "s/^.fp=//g" | sed "s/&.$//g")
SERVER_NAME_SNI=$(echo "$FULL_STRING" | sed "s/^.sni=//g" | sed "s/&.$//g")
PUBLIC_KEY_PBK=$(echo "$FULL_STRING" | sed "s/^.pbk=//g" | sed "s/&.$//g")
SHORT_ID_SID=$(echo "$FULL_STRING" | sed "s/^.sid=//g" | sed "s/&.$//g")
FLOW=$(echo "$FULL_STRING" | sed "s/^.flow=//g" | sed "s/#.$//g")
SPIDERX=$(echo "$FULL_STRING" | sed "s/^.spx=//g" | sed "s/&.$//g" | sed "s/%2F///g")
echo "TCP(RAW) config:"
echo "NETWORK: $NETWORK"
echo "USER_ID: $USER_ID"
echo "SERVER_ADDRESS: $SERVER_ADDRESS"
echo "SERVER_PORT: $SERVER_PORT"
echo "ENCRYPTION: $ENCRYPTION"
echo "FINGERPRINT_FP: $FINGERPRINT_FP"
echo "SERVER_NAME_SNI: $SERVER_NAME_SNI"
echo "PUBLIC_KEY_PBK: $PUBLIC_KEY_PBK"
echo "SHORT_ID_SID: $SHORT_ID_SID"
echo "FLOW: $FLOW"
echo "SPIDERX: $SPIDERX"

cat < /opt/xray/config/config.json
{
"log": {
"loglevel": "silent"
},
"inbounds": [
{
"port": 10800,
"listen": "0.0.0.0",
"protocol": "socks",
"settings": {
"udp": true
},
"sniffing": {
"enabled": false,
"destOverride": ["http", "tls", "quic"],
"routeOnly": true
}
}
],
"outbounds": [
{
"protocol": "vless",
"settings": {
"vnext": [
{
"address": "$SERVER_ADDRESS",
"port": $SERVER_PORT,
"users": [
{
"id": "$USER_ID",
"encryption": "$ENCRYPTION",
"flow": "$FLOW"
}
]
}
]
},
"streamSettings": {
"network": "$NETWORK",
"security": "reality",
"realitySettings": {
"fingerprint": "$FINGERPRINT_FP",
"serverName": "$SERVER_NAME_SNI",
"publicKey": "$PUBLIC_KEY_PBK",
"spiderX": "$SPIDERX",
"shortId": "$SHORT_ID_SID"
}
},
"tag": "proxy"
}
]
}
EOF
