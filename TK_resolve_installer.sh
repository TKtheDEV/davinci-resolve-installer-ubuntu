#!/bin/bash

# Enable error handling
set -euo pipefail

# Variables
DOWNLOADS_DIR=~/Downloads
PACKAGE_NAME="DaVinci_Resolve"
LIB_PATH="/usr/lib/x86_64-linux-gnu"
RESOLVE_LIBS_PATH="/opt/resolve/libs"

# Auto-detect the ZIP file
ZIP_FILE=$(find "$DOWNLOADS_DIR" -maxdepth 1 -type f -name "${PACKAGE_NAME}_*_Linux.zip" | sort -V | tail -n 1)

if [[ -z "$ZIP_FILE" ]]; then
    echo "Error: No DaVinci Resolve ZIP file found in $DOWNLOADS_DIR."
    exit 1
fi

# Extract version number from the ZIP filename
VERSION=$(echo "$ZIP_FILE" | grep -oP '(?<=DaVinci_Resolve_)\d+\.\d+(\.\d+)?' || echo "unknown")
INSTALLER_DIR="$DOWNLOADS_DIR/${PACKAGE_NAME}_${VERSION}_Linux"
INSTALLER_RUN="$INSTALLER_DIR/${PACKAGE_NAME}_${VERSION}_Linux.run"

echo "Detected ZIP file: $ZIP_FILE"
echo "Detected version: $VERSION"

# Unzip the package
echo "Unzipping $ZIP_FILE..."
unzip -o "$ZIP_FILE" -d "$INSTALLER_DIR"

# Install dependencies
echo "Installing required dependencies..."
sudo apt update && sudo apt install -y libapr1t64 libaprutil1t64 libxcb-composite0 libxcb-xinerama0 libfuse2

# Check if the installer exists
if [[ ! -f "$INSTALLER_RUN" ]]; then
    echo "Error: Installer $INSTALLER_RUN not found after extraction."
    exit 1
fi

# Run the installer
echo "Running the installer..."
sudo SKIP_PACKAGE_CHECK=1 "$INSTALLER_RUN" -i

# Copy necessary libraries
echo "Copying required libraries to Resolve's lib directory..."
for lib in libgio-2.0.so.0 libgmodule-2.0.so.0 libglib-2.0.so.0; do
    if [[ -f "$LIB_PATH/$lib" ]]; then
        sudo cp "$LIB_PATH/$lib" "$RESOLVE_LIBS_PATH/"
    else
        echo "Warning: $lib not found in $LIB_PATH. Resolve may not function correctly."
    fi
done

# Cleaning up but leaving the zip file in place
echo "Cleaning Up..."
rm -r "$INSTALLER_DIR"

echo "All done! You can open Resolve now. Have fun! ~TKtheDEV"
