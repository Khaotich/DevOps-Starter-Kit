#!/usr/bin/env bash

set -e

TARGET_DIR="$HOME/.local/bin"
mkdir -p "$TARGET_DIR"

# Fetch the latest version tag from the GitHub API
echo "Checking for the latest SOPS version..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/getsops/sops/releases/latest | grep -o '"tag_name": *"[^"]*"' | cut -d'"' -f4)

if [ -z "$LATEST_VERSION" ]; then
    echo "Failed to determine the latest SOPS version."
    exit 1
fi

# Detect OS and architecture to match SOPS binary releases
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

BINARY_URL="https://github.com/getsops/sops/releases/download/${LATEST_VERSION}/sops-${LATEST_VERSION}.${OS}.${ARCH}"

# Download binary directly (SOPS releases are uncompressed executables)
echo "Downloading SOPS ${LATEST_VERSION}..."
TMP_FILE=$(mktemp)
curl -# -L -o "$TMP_FILE" "$BINARY_URL"

echo "Installing binary to $TARGET_DIR..."
mv "$TMP_FILE" "$TARGET_DIR/sops"
chmod +x "$TARGET_DIR/sops"

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
if [ -f "$TARGET_DIR/sops" ]; then
    echo -e "\nInstallation successful:"
    "$TARGET_DIR/sops" --version
else
    echo "Installation failed."
    exit 1
fi