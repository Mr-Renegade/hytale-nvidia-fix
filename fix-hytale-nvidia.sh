#!/bin/bash
#
# Hytale NVIDIA GPU Fix Script
# Automatically installs the correct NVIDIA flatpak GL extension
#

set -e

echo "=========================================="
echo "Hytale NVIDIA GPU Fix"
echo "=========================================="
echo ""

# Check if nvidia-smi is available
if ! command -v nvidia-smi &> /dev/null; then
    echo "ERROR: nvidia-smi not found!"
    echo "This script requires NVIDIA drivers to be installed."
    exit 1
fi

# Check if flatpak is available
if ! command -v flatpak &> /dev/null; then
    echo "ERROR: flatpak not found!"
    echo "This script requires flatpak to be installed."
    exit 1
fi

# Get NVIDIA driver version
echo "[1/4] Detecting NVIDIA driver version..."
DRIVER_VERSION=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader | head -1)

if [ -z "$DRIVER_VERSION" ]; then
    echo "ERROR: Could not detect NVIDIA driver version"
    exit 1
fi

echo "Found NVIDIA driver version: $DRIVER_VERSION"

# Convert version format (dots to dashes)
EXTENSION_VERSION=$(echo "$DRIVER_VERSION" | sed 's/\./-/g')
EXTENSION_NAME="org.freedesktop.Platform.GL.nvidia-$EXTENSION_VERSION"

echo ""
echo "[2/4] Checking if extension is available..."

# Check if extension exists on flathub
if ! flatpak remote-ls flathub | grep -q "$EXTENSION_NAME"; then
    echo "WARNING: Exact extension not found: $EXTENSION_NAME"
    echo ""
    echo "Available NVIDIA extensions for your driver series:"
    DRIVER_MAJOR=$(echo "$DRIVER_VERSION" | cut -d'.' -f1)
    flatpak remote-ls flathub | grep "GL.nvidia-$DRIVER_MAJOR" | head -10
    echo ""
    echo "You may need to:"
    echo "  1. Install a different driver version that has an extension"
    echo "  2. Wait for the extension to be added to flathub"
    echo "  3. Manually install the closest available version"
    exit 1
fi

echo "Extension found: $EXTENSION_NAME"

# Check if already installed
if flatpak list | grep -q "$EXTENSION_NAME"; then
    echo ""
    echo "Extension is already installed!"
    echo "Your Hytale should already be using NVIDIA GPU."
    echo ""
    echo "To verify:"
    echo "  1. Launch Hytale"
    echo "  2. Enable Developer Mode in settings"
    echo "  3. Press F7 to see debug overlay"
    echo "  4. Check RENDERING section for NVIDIA GPU"
    exit 0
fi

# Install the extension
echo ""
echo "[3/4] Installing NVIDIA flatpak GL extension..."
echo "This will download ~300-350 MB"
echo ""

flatpak install -y flathub "$EXTENSION_NAME"

# Verify installation
echo ""
echo "[4/4] Verifying installation..."

if flatpak list | grep -q "$EXTENSION_NAME"; then
    echo ""
    echo "=========================================="
    echo "✅ SUCCESS! Extension installed!"
    echo "=========================================="
    echo ""
    echo "NVIDIA GL Extension: $EXTENSION_NAME"
    echo ""
    echo "Next steps:"
    echo "  1. Launch Hytale: flatpak run com.hypixel.HytaleLauncher"
    echo "  2. Enable Developer Mode in Hytale settings"
    echo "  3. Press F7 in-game to verify GPU is NVIDIA"
    echo ""
    echo "Expected result: 4-5x FPS improvement!"
    echo ""
else
    echo ""
    echo "ERROR: Extension installation failed!"
    echo "Please try manual installation or check the README.md"
    exit 1
fi
