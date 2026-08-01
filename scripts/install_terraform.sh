#!/usr/bin/env bash

set -e

TARGET_DIR="$HOME/.local/bin"
mkdir -p "$TARGET_DIR"

# Fetch the latest version from the HashiCorp API
echo "Checking for the latest Terraform version..."
LATEST_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | grep -o '"current_version":"[^"]*"' | cut -d'"' -f4)

if [ -z "$LATEST_VERSION" ]; then
    echo "Failed to determine the latest Terraform version."
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

ZIP_URL="https://releases.hashicorp.com/terraform/${LATEST_VERSION}/terraform_${LATEST_VERSION}_${OS}_${ARCH}.zip"

# Download and extract the archive
echo "Downloading Terraform $LATEST_VERSION..."
TMP_DIR=$(mktemp -d)
curl -# -L -o "$TMP_DIR/terraform.zip" "$ZIP_URL"

echo "Extracting to $TARGET_DIR..."
unzip -q -o "$TMP_DIR/terraform.zip" -d "$TARGET_DIR"
rm -rf "$TMP_DIR"

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
if [ -f "$TARGET_DIR/terraform" ]; then
    echo -e "\nInstallation successful:"
    "$TARGET_DIR/terraform" --version
else
    echo "Installation failed."
    exit 1
fi