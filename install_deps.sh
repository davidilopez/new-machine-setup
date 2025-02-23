#!/bin/sh
# This script checks for basic dependencies for the system, and installs them if they are not present.
# It uses Nix package manager to install the dependencies across different systems.
# If Nix is not present, it installs it first.

# Check architecture and operating system
ARCH=$(uname -m)
OS=$(uname -s)

# Check if Nix is installed
if ! command -v nix-env > /dev/null; then
  # Install Nix
  sh <(curl -L https://nixos.org/nix/install) --daemon
fi

# Install dependencies
if [ "$OS" = "Darwin" ]; then
  read -p "Would you like to configure nix-darwin? (y/n): " response
  if [ "$response" = "y" ]; then
    sh <(curl -L https://raw.githubusercontent.com/davidilopez/macos-setup/refs/heads/main/nix-darwin-setup.sh)
  fi
fi