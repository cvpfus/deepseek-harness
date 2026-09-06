#!/bin/bash
set -e

: "${DSH_PUBLIC_HOST:?set DSH_PUBLIC_HOST to the exact domain Coolify serves this app on}"

pnpm dsh web --no-open --port 3080 --trusted-host "$DSH_PUBLIC_HOST" &
DSH_PID=$!

until nc -z 127.0.0.1 3080 2>/dev/null; do sleep 0.2; done

socat TCP-LISTEN:8080,fork,reuseaddr TCP:127.0.0.1:3080 &
SOCAT_PID=$!

trap 'kill -TERM $DSH_PID $SOCAT_PID 2>/dev/null' TERM INT
wait -n "$DSH_PID" "$SOCAT_PID"
