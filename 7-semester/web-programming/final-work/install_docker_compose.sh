#!/bin/bash

# Exit on error
set -e

echo "=== SkyTracker Environment & Docker Compose Setup Script ==="

# 1. Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "[!] Docker CLI is not installed. Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg lsb-release
    
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg || true
    
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
else
    echo "[✓] Docker is already installed."
fi

# 2. Check if Docker Compose plugin is installed
if ! docker compose version &> /dev/null && ! command -v docker-compose &> /dev/null; then
    echo "[+] Installing Docker Compose plugin..."
    sudo apt-get update
    sudo apt-get install -y docker-compose-plugin || sudo apt-get install -y docker-compose
else
    echo "[✓] Docker Compose is already installed."
fi

# Print Docker Compose version
if docker compose version &> /dev/null; then
    echo "[✓] Version: $(docker compose version)"
    COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    echo "[✓] Version: $(docker-compose --version)"
    COMPOSE_CMD="docker-compose"
fi

# 3. Add current user to docker group if needed
if ! groups $USER | grep &>/dev/null '\bdocker\b'; then
    echo "[+] Adding $USER to docker group..."
    sudo usermod -aG docker $USER || true
    echo "[!] Note: You may need to log out and log back in or run 'newgrp docker' for non-sudo docker usage."
fi

echo ""
echo "=== Docker & Docker Compose setup completed successfully! ==="
echo ""
echo "To launch your SkyTracker project, run:"
echo "  cd /home/artjoms/projects/uni/7-semester/web-programming/final-work"
echo "  $COMPOSE_CMD up --build -d"
echo ""
