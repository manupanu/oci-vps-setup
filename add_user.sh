#!/usr/bin/env bash

# Exit on error
set -e

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root or with sudo"
    exit 1
fi

# Check if username is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <username> [ssh_public_key_path]"
    exit 1
fi

USERNAME=$1
SSH_KEY_PATH=$2

echo "Creating user: $USERNAME"

# Create user with home directory
useradd -m -s /bin/bash "$USERNAME"

# Set up sudo access
usermod -aG sudo "$USERNAME"

# Create SSH directory with correct permissions
USER_HOME="/home/$USERNAME"
SSH_DIR="$USER_HOME/.ssh"
mkdir -p "$SSH_DIR"
chown "$USERNAME:$USERNAME" "$SSH_DIR"
chmod 700 "$SSH_DIR"

# If SSH key is provided, add it to authorized_keys
if [ ! -z "$SSH_KEY_PATH" ]; then
    if [ -f "$SSH_KEY_PATH" ]; then
        cat "$SSH_KEY_PATH" > "$SSH_DIR/authorized_keys"
        chown "$USERNAME:$USERNAME" "$SSH_DIR/authorized_keys"
        chmod 600 "$SSH_DIR/authorized_keys"
        echo "SSH key added successfully"
    else
        echo "SSH key file not found: $SSH_KEY_PATH"
        exit 1
    fi
fi

# Force password change on first login
passwd -e "$USERNAME"

echo "User $USERNAME created successfully!"
echo "Please set an initial password for $USERNAME"
passwd "$USERNAME"