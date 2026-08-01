#!/usr/bin/env bash

set -e

TARGET_DIR="$HOME/.local/bin"
mkdir -p "$TARGET_DIR"

# Fetch the latest version from GitHub API
echo "Checking for the latest Terragrunt version..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4)

if [ -z "$LATEST_VERSION" ]; then
    echo "Failed to determine the latest Terragrunt version."
    exit 1
fi

# Detect OS and architecture to download the correct binary
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
case $ARCH in
    x86_64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) echo "Architecture $ARCH is not supported by this script."; exit 1 ;;
esac

DOWNLOAD_URL="https://github.com/gruntwork-io/terragrunt/releases/download/${LATEST_VERSION}/terragrunt_${OS}_${ARCH}"

# Download the executable directly to the target directory
echo "Downloading Terragrunt $LATEST_VERSION..."
curl -# -L -o "$TARGET_DIR/terragrunt" "$DOWNLOAD_URL"

# Make the downloaded file executable
chmod +x "$TARGET_DIR/terragrunt"

# Update PATH in shell configuration files
SHELL_RC=""
if [[ "$SHELL" == */zsh ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ "$SHELL" == */bash ]]; then
    SHELL_RC="$HOME/.bashrc"
fi

if [ -n "$SHELL_RC" ] && [ -f "$SHELL_RC" ]; then
    if ! grep -q "$TARGET_DIR" "$SHELL_RC"; then
        echo -e "\nexport PATH=\"\$PATH:$TARGET_DIR\"" >> "$SHELL_RC"
        echo "PATH updated in $SHELL_RC. Run 'source $SHELL_RC' to apply."
    fi
fi

# Verify installation
if [ -f "$TARGET_DIR/terragrunt" ]; then
    echo -e "\nInstallation successful:"
    "$TARGET_DIR/terragrunt" --version
else
    echo "Installation failed."
    exit 1
fi