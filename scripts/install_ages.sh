#!/usr/bin/env bash

set -e

TARGET_DIR="$HOME/.local/bin"
mkdir -p "$TARGET_DIR"

# Fetch the latest version tag from the GitHub API
echo "Checking for the latest age version..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/FiloSottile/age/releases/latest | grep -o '"tag_name": *"[^"]*"' | cut -d'"' -f4)

if [ -z "$LATEST_VERSION" ]; then
    echo "Failed to determine the latest age version."
    exit 1
fi

# Detect OS and architecture to match age release archives
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case $OS in
    linux) OS="linux" ;;
    darwin) OS="darwin" ;;
    *) echo "Operating system $OS is not supported by this script."; exit 1 ;;
esac

case $ARCH in
    x86_64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) echo "Architecture $ARCH is not supported by this script."; exit 1 ;;
esac

TAR_URL="https://github.com/FiloSottile/age/releases/download/${LATEST_VERSION}/age-${LATEST_VERSION}-${OS}-${ARCH}.tar.gz"

# Download and extract the archive (contains both 'age' and 'age-keygen')
echo "Downloading age ${LATEST_VERSION}..."
TMP_DIR=$(mktemp -d)
curl -# -L -o "$TMP_DIR/age.tar.gz" "$TAR_URL"

echo "Extracting binaries to $TARGET_DIR..."
tar -xzf "$TMP_DIR/age.tar.gz" -C "$TMP_DIR"

# Move binaries from extracted directory
mv "$TMP_DIR/age/age" "$TARGET_DIR/age"
mv "$TMP_DIR/age/age-keygen" "$TARGET_DIR/age-keygen"
chmod +x "$TARGET_DIR/age" "$TARGET_DIR/age-keygen"

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
if [ -f "$TARGET_DIR/age" ] && [ -f "$TARGET_DIR/age-keygen" ]; then
    echo -e "\nInstallation successful:"
    "$TARGET_DIR/age" --version
else
    echo "Installation failed."
    exit 1
fi