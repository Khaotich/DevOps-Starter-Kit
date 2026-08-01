#!/usr/bin/env bash

set -e

TARGET_DIR="$HOME/.local/bin"
mkdir -p "$TARGET_DIR"

sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b "$TARGET_DIR"

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

if [ -f "$TARGET_DIR/task" ]; then
    "$TARGET_DIR/task" --version
else
    echo "Installation failed."
    exit 1
fi