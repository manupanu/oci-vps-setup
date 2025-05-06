#!/usr/bin/env bash

# Exit on error
set -e

echo "Starting initial system setup..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root or with sudo"
    exit 1
fi

# Function to install a package if not already installed
install_if_missing() {
    if ! dpkg -l "$1" &> /dev/null; then
        echo "Installing $1..."
        nala install -y "$1"
    else
        echo "$1 is already installed"
    fi
}

# Check if nala is installed
if ! command -v nala &> /dev/null; then
    echo "nala is not installed. Installing nala..."
    apt-get update
    apt-get install nala -y
fi

# Update package lists
echo "Updating package lists..."
nala update

# Perform system upgrade
echo "Upgrading system packages..."
nala upgrade -y

# Install required packages
PACKAGES="git nala nano vim"
for pkg in $PACKAGES; do
    install_if_missing "$pkg"
done

echo "Initial setup completed successfully!"
