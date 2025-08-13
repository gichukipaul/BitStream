#!/bin/sh

#  setup_ytdlp.sh
#  BitStream
#
#  Created by GICHUKI on 14/08/2025.
#  
#/Users/gichuki/Downloads/YT-Downloads/yt-dlp
# Setup script for downloading and integrating yt-dlp into the Xcode project
# Run this script from your project root directory

set -e

PROJECT_ROOT="$(pwd)"
RESOURCES_DIR="$PROJECT_ROOT/BitStream/Resources"
YTDLP_PATH="$RESOURCES_DIR/yt-dlp"

echo "Setting up yt-dlp for BitStream..."

# Create Resources directory if it doesn't exist
mkdir -p "$RESOURCES_DIR"

# Download latest yt-dlp binary for macOS
echo "Downloading yt-dlp..."
curl -L "https://github.com/yt-dlp/yt-dlp/releases/latest/download/ yt-dlp" -o "$YTDLP_PATH"

# Make it executable
chmod +x "$YTDLP_PATH"

# Verify the binary works
echo "Verifying yt-dlp installation..."
if "$YTDLP_PATH" --version > /dev/null 2>&1; then
    echo "✅ yt-dlp successfully downloaded and verified"
    "$YTDLP_PATH" --version
else
    echo "❌ Failed to verify yt-dlp installation"
    exit 1
fi

echo ""
echo "Setup complete! Next steps:"
echo "1. Add the Resources folder to your Xcode project"
echo "2. Ensure yt-dlp is included in Copy Bundle Resources build phase"
echo "3. Build and run your app"
echo ""
echo "Note: You may need to notarize the app for distribution due to the bundled binary."
