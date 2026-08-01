#!/usr/bin/env bash

set -e

TARGET_DIR="$HOME/.local/bin"
mkdir -p "$TARGET_DIR"

# Check if Python 3 and pip are installed, as Ansible requires them
if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: python3 is required but not installed."
    exit 1
fi

if ! command -v pip3 >/dev/null 2>&1 && ! python3 -m pip --version >/dev/null 2>&1; then
    echo "Error: pip for python3 is required but not installed."
    exit 1
fi

# Install Ansible for the current user using pip
# This will automatically place the ansible binary in ~/.local/bin
echo "Installing Ansible via pip..."
python3 -m pip install --user ansible

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
# Pip might place it directly in PATH if it's already sourced, or in TARGET_DIR
if [ -f "$TARGET_DIR/ansible" ]; then
    echo -e "\nInstallation successful:"
    "$TARGET_DIR/ansible" --version
elif command -v ansible >/dev/null 2>&1; then
    echo -e "\nInstallation successful:"
    ansible --version
else
    echo "Installation failed. Ansible executable not found in $TARGET_DIR."
    exit 1
fi