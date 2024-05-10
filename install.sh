#!/bin/bash

# URL of the script to download
URL="https://raw.githubusercontent.com/denisklp/secret-check-pre-commit/main/pre-commit"

# Destination directory for the downloaded script
DEST_DIR="$(git rev-parse --git-dir)/hooks"

# Path to the downloaded script
DEST_SCRIPT="$DEST_DIR/pre-commit"

# Download the script
echo "Downloading script from $URL..."
curl -sSfL "$URL" > "$DEST_SCRIPT"

# Make the script executable
chmod +x "$DEST_SCRIPT"

echo "Script downloaded and made executable at $DEST_SCRIPT"
