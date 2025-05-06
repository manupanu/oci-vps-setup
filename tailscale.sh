#!/usr/bin/env bash

# Exit on error
set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root or with sudo"
    exit 1
fi

# Check if Tailscale is already installed
if command -v tailscale &> /dev/null; then
    echo "Tailscale is already installed"
    echo "Current status:"
    tailscale status
    exit 0
fi

echo "Installing Tailscale..."

# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Check if installation was successful
if command -v tailscale &> /dev/null; then
    echo "Tailscale installed successfully!"
    echo "To connect to your Tailscale network, run:"
    echo "sudo tailscale up"
else
    echo "Error: Tailscale installation failed"
    exit 1
fi
