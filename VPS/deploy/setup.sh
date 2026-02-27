#!/bin/bash
# VPS Initial Setup Script for VivaClub
# Run this script as root on your brand new Contabo VPS.

# 1. Update OS and Install fundamentals
echo "🚀 Updating System & Installing Essentials..."
apt update && apt upgrade -y
apt install -y curl wget git ufw nano unzip jq

# 2. Configure UFW Firewall
echo "🛡️ Configuring Firewall (UFW)..."
ufw allow 22/tcp            # SSH
ufw allow 80/tcp            # HTTP (Let's Encrypt / Caddy)
ufw allow 443/tcp           # HTTPS (Caddy / API)
ufw allow 7880/tcp          # LiveKit WebRTC HTTP
ufw allow 7881/tcp          # LiveKit RPC
ufw allow 7882/tcp          # LiveKit TURN TCP
ufw allow 7882/udp          # LiveKit TURN UDP
ufw allow 50000:60000/udp   # LiveKit Media Ports (CRITICAL!)
ufw --force enable

# 3. Install Docker & Docker Compose
echo "🐳 Installing Docker & Docker Compose..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh
systemctl enable docker
systemctl start docker

# Install Docker Compose (v2)
apt install docker-compose-plugin -y

# 4. Clone Project / Create Directory
echo "📁 Preparing application folder..."
mkdir -p /app/vivaclub
cd /app/vivaclub

echo "✅ VPS Pre-requisites Installed Successfully!"
echo "➡️ Next step: Upload docker-compose.yml, Caddyfile, livekit.yaml, and .env to /app/vivaclub and run 'docker compose up -d'"
