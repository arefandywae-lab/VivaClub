#!/bin/bash
# VPS Setup Script - Run this after initial VPS provisioning

set -e

echo "=== VivaClub VPS Setup Script ==="
echo "This script will install and configure all required software"
echo ""

# Update system
echo "1. Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker
echo "2. Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "Docker installed successfully"
else
    echo "Docker already installed"
fi

# Install Docker Compose
echo "3. Installing Docker Compose..."
sudo apt install docker-compose-plugin -y

# Install Nginx
echo "4. Installing Nginx..."
sudo apt install nginx -y

# Install Certbot (SSL)
echo "5. Installing Certbot..."
sudo apt install certbot python3-certbot-nginx -y

# Install monitoring tools
echo "6. Installing monitoring tools..."
sudo apt install htop iotop nethogs -y

# Install rclone (for Google Drive backup)
echo "7. Installing rclone..."
if ! command -v rclone &> /dev/null; then
    curl https://rclone.org/install.sh | sudo bash
    echo "rclone installed successfully"
else
    echo "rclone already installed"
fi

# Setup firewall
echo "8. Configuring firewall..."
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 7880/tcp
sudo ufw allow 7881/udp
sudo ufw allow 50000:50100/udp
sudo ufw allow 3478/udp
sudo ufw allow 5349/tcp
sudo ufw --force enable

# Create deployment directory
echo "9. Creating deployment directory..."
mkdir -p ~/vivaclub
mkdir -p ~/backups

# Generate strong passwords
echo "10. Generating secure passwords..."
DB_PASSWORD=$(openssl rand -base64 32)
REDIS_PASSWORD=$(openssl rand -base64 32)
MINIO_PASSWORD=$(openssl rand -base64 32)
LIVEKIT_SECRET=$(openssl rand -base64 32)
DJANGO_SECRET=$(openssl rand -base64 50)

# Create .env.production template
echo "11. Creating .env.production template..."
cat > ~/vivaclub/.env.production.template << EOF
# Database
DATABASE_URL=postgresql://vivaclub:${DB_PASSWORD}@postgres:5432/vivaclub
DB_PASSWORD=${DB_PASSWORD}

# Redis
REDIS_URL=redis://:${REDIS_PASSWORD}@redis:6379
REDIS_PASSWORD=${REDIS_PASSWORD}

# MinIO
MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=${MINIO_PASSWORD}
AWS_ACCESS_KEY_ID=admin
AWS_SECRET_ACCESS_KEY=${MINIO_PASSWORD}
AWS_STORAGE_BUCKET_NAME=vivaclub-media
AWS_S3_ENDPOINT_URL=http://minio:9000
DOMAIN=yourdomain.com

# LiveKit
LIVEKIT_API_URL=wss://yourdomain.com/livekit
LIVEKIT_API_KEY=APIxxxxxxxxx
LIVEKIT_API_SECRET=${LIVEKIT_SECRET}

# Firebase
GOOGLE_APPLICATION_CREDENTIALS=/app/firebase-credentials.json

# Django
SECRET_KEY=${DJANGO_SECRET}
DEBUG=False
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com

# GitHub (for Docker image)
GITHUB_USERNAME=your-github-username
EOF

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Next steps:"
echo "1. Configure rclone for Google Drive:"
echo "   rclone config"
echo ""
echo "2. Edit .env.production.template and save as .env.production"
echo "   cd ~/vivaclub"
echo "   nano .env.production.template"
echo ""
echo "3. Setup domain and SSL:"
echo "   sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com"
echo ""
echo "4. Deploy the application:"
echo "   cd ~/vivaclub"
echo "   docker-compose -f docker-compose.prod.yml up -d"
echo ""
echo "5. Setup backup cron job:"
echo "   crontab -e"
echo "   # Add: 0 2 * * * /home/deploy/vivaclub/scripts/backup.sh >> /home/deploy/backups/backup.log 2>&1"
echo ""
echo "Generated passwords saved in .env.production.template"
echo "IMPORTANT: Keep these passwords secure!"
