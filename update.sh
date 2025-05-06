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

echo "Updating package lists..."
nala update

echo "Upgrading packages..."
nala upgrade -y

echo "System update completed successfully!"
