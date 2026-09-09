#!/bin/bash
set -e

HOST_IP="${HOST_IP:?HOST_IP is required}"
PORT="${PORT:-26379}"
MASTER_NAME="${MASTER_NAME:-cache-master}"
MASTER_IP="${MASTER_IP:?MASTER_IP is required}"
MASTER_PORT="${MASTER_PORT:-6379}"
QUORUM="${QUORUM:-2}"



export HOST_IP
export PORT
export MASTER_NAME
export MASTER_IP
export MASTER_PORT
export QUORUM

TEMPLATE=/opt/sentinel/sentinel.conf.template
CONF=/etc/redis/sentinel.conf

if [ ! -f "$CONF" ]; then
  envsubst < "$TEMPLATE" > "$CONF"
fi

echo "=============================="
echo "Generated sentinel.conf:"
cat "$CONF"
echo "=============================="

exec redis-sentinel "$CONF"
