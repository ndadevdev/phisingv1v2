#!/bin/bash
# Auto-setup: check & install semua requirements
# Usage: ./setup.sh

echo ""
echo "═══════════════════════════════════════"
echo "  AUTO SETUP - Checking Requirements"
echo "═══════════════════════════════════════"
echo ""

# Detect OS
OS="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    OS="windows"
fi

echo "[*] Detected OS: $OS"
echo ""

MISSING=0

# ---- PYTHON ----
echo -n "[*] Python 3 ... "
if command -v python3 &> /dev/null; then
    echo "✅ $(python3 --version)"
elif command -v python &> /dev/null; then
    echo "✅ $(python --version)"
else
    echo "❌ NOT FOUND"
    MISSING=1
    if [ "$OS" == "linux" ]; then
        echo "    → Installing Python 3..."
        sudo apt update && sudo apt install -y python3
    elif [ "$OS" == "macos" ]; then
        echo "    → Installing Python 3..."
        brew install python3
    elif [ "$OS" == "windows" ]; then
        echo "    → Download: https://www.python.org/downloads/"
        echo "    → Centang 'Add to PATH' saat install!"
    fi
fi

# ---- CLOUDFLARED ----
echo -n "[*] Cloudflared ... "
if command -v cloudflared &> /dev/null; then
    echo "✅ $(cloudflared --version 2>&1 | head -1)"
else
    echo "❌ NOT FOUND"
    MISSING=1
    if [ "$OS" == "linux" ]; then
        echo "    → Installing Cloudflared..."
        curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
        echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main" | sudo tee /etc/apt/sources.list.d/cloudflared.list
        sudo apt update && sudo apt install -y cloudflared
    elif [ "$OS" == "macos" ]; then
        echo "    → Installing Cloudflared..."
        brew install cloudflared
    elif [ "$OS" == "windows" ]; then
        echo "    → Installing Cloudflared..."
        winget install cloudflare.cloudflared
    fi
fi

# ---- GIT ----
echo -n "[*] Git ... "
if command -v git &> /dev/null; then
    echo "✅ $(git --version)"
else
    echo "❌ NOT FOUND"
    MISSING=1
    if [ "$OS" == "linux" ]; then
        echo "    → Installing Git..."
        sudo apt update && sudo apt install -y git
    elif [ "$OS" == "macos" ]; then
        echo "    → Installing Git..."
        brew install git
    elif [ "$OS" == "windows" ]; then
        echo "    → Installing Git..."
        winget install git
    fi
fi

# ---- XCLIP (optional) ----
echo -n "[*] Xclip (optional, auto-copy) ... "
if command -v xclip &> /dev/null; then
    echo "✅ installed"
else
    echo "⚠️  not found (optional)"
    if [ "$OS" == "linux" ]; then
        echo "    → Installing Xclip..."
        sudo apt install -y xclip
    fi
fi

echo ""
echo "═══════════════════════════════════════"

if [ $MISSING -eq 0 ]; then
    echo "  ✅ Semua requirements terinstall!"
    echo ""
    echo "  Jalankan: ./run.sh"
else
    echo "  ⚠️  Ada yang gagal install."
    echo "  Install manual lalu jalankan: ./run.sh"
fi

echo "═══════════════════════════════════════"
echo ""
