#!/bin/bash
set -e

KEEPALIVED_STATE="${KEEPALIVED_STATE:-BACKUP}"
KEEPALIVED_ROUTER_ID="${KEEPALIVED_ROUTER_ID:-2}"
KEEPALIVED_AUTH_PASS="${KEEPALIVED_AUTH_PASS:-12345}"
KEEPALIVED_PRIORITY="${KEEPALIVED_PRIORITY:-100}"


if [ "$KEEPALIVED_STATE" = "MASTER" ]; then
  KEEPALIVED_PRIORITY=200
else
  KEEPALIVED_PRIORITY="${KEEPALIVED_PRIORITY:-100}"
fi



if [ -n "$KEEPALIVED_UNICAST_PEERS" ]; then
  KEEPALIVED_UNICAST_PEER_BLOCK=$(echo "$KEEPALIVED_UNICAST_PEERS" | tr ',' '\n' | sed 's/^/        /')
  KEEPALIVED_UNICAST_PEER_BLOCK=$(echo "$KEEPALIVED_UNICAST_PEER_BLOCK" | sed ':a;N;$!ba;s/\n/\\n/g')
else
  KEEPALIVED_UNICAST_PEER_BLOCK=""
fi

export KEEPALIVED_STATE
export KEEPALIVED_PRIORITY
export KEEPALIVED_ROUTER_ID
export KEEPALIVED_AUTH_PASS

envsubst < /etc/keepalived/keepalived.conf.template > /etc/keepalived/keepalived.conf.tmp
sed "s|@KEEPALIVED_UNICAST_PEERS@|${KEEPALIVED_UNICAST_PEER_BLOCK}|g" /etc/keepalived/keepalived.conf.tmp > /etc/keepalived/keepalived.conf

echo "=============================="
echo "Generated keepalived.conf:"
cat /etc/keepalived/keepalived.conf
echo "=============================="

exec keepalived "$@"
