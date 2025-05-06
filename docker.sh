#!/usr/bin/env bash

# Exit on error
set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root or with sudo"
    exit 1
fi

# Check if nala is installed
if ! command -v nala &> /dev/null; then
    echo "nala is not installed. Installing nala..."
    apt-get update
    apt-get install nala -y
fi

echo "Setting up Docker..."

# Remove conflicting packages
echo "Removing any conflicting packages..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do 
    if dpkg -l | grep -q "^ii.*$pkg"; then
        echo "Removing $pkg..."
        nala remove -y $pkg
    fi
done

# Set up Docker repository
echo "Setting up Docker repository..."
nala update
nala install -y ca-certificates curl gnupg

# Create keyrings directory if it doesn't exist
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo "Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
echo "Installing Docker packages..."
nala update
nala install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify installation
if systemctl is-active --quiet docker; then
    echo "Docker service is running"
else
    echo "Starting Docker service..."
    systemctl start docker
fi

# Test Docker installation
echo "Testing Docker installation..."
docker run hello-world

echo "Docker installation completed successfully!"
echo "To use Docker without sudo, run: sudo usermod -aG docker \$USER"

