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

echo "🚀 Setting up standalone yt-dlp for BitStream..."

# Create Resources directory if it doesn't exist
mkdir -p "$RESOURCES_DIR"

# Method 1: Try the universal binary first
echo "📥 Downloading yt-dlp universal binary..."
if curl -L "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp" -o "$YTDLP_PATH"; then
    chmod +x "$YTDLP_PATH"
    
    # Test if it works without sandbox restrictions
    echo "🧪 Testing yt-dlp binary..."
    if timeout 10s "$YTDLP_PATH" --version > /dev/null 2>&1; then
        echo "✅ Method 1: Universal binary works!"
        echo "yt-dlp version: $($YTDLP_PATH --version)"
        exit 0
    else
        echo "❌ Method 1: Universal binary has dependencies, trying Method 2..."
        rm -f "$YTDLP_PATH"
    fi
fi

# Method 2: Build standalone with PyInstaller
echo "🐍 Building standalone yt-dlp with PyInstaller..."

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed. Please install Python 3 and try again."
    exit 1
fi

# Create temporary build environment
BUILD_DIR="$PROJECT_ROOT/.yt-dlp-build"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "📦 Creating Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

echo "📚 Installing dependencies..."
pip install --upgrade pip
pip install yt-dlp pyinstaller

echo "🔨 Building standalone binary..."
# Create a simple launcher script
cat > yt_dlp_launcher.py << 'EOF'
#!/usr/bin/env python3
import sys
import yt_dlp

if __name__ == '__main__':
    yt_dlp.main()
EOF

# Build standalone executable
pyinstaller --onefile \
    --name yt-dlp \
    --distpath . \
    --workpath ./build \
    --specpath ./build \
    --clean \
    --noconfirm \
    yt_dlp_launcher.py

# Copy to resources
if [ -f "yt-dlp" ]; then
    cp "yt-dlp" "$YTDLP_PATH"
    chmod +x "$YTDLP_PATH"
    
    # Test the built binary
    echo "🧪 Testing built binary..."
    if timeout 10s "$YTDLP_PATH" --version > /dev/null 2>&1; then
        echo "✅ Method 2: Standalone binary works!"
        echo "yt-dlp version: $($YTDLP_PATH --version)"
        
        # Clean up
        cd "$PROJECT_ROOT"
        rm -rf "$BUILD_DIR"
        
        echo ""
        echo "🎉 Setup complete! yt-dlp is ready to use."
        echo "📍 Binary location: $YTDLP_PATH"
        echo "📦 Size: $(du -h "$YTDLP_PATH" | cut -f1)"
        echo ""
        echo "Next steps:"
        echo "1. Add the Resources folder to your Xcode project (if not already added)"
        echo "2. Ensure yt-dlp is included in Copy Bundle Resources build phase"
        echo "3. Build and run your app"
        echo ""
        echo "⚠️  Note: The standalone binary will be larger (~50MB) but has no external dependencies."
        
        exit 0
    else
        echo "❌ Method 2: Built binary failed to run"
    fi
else
    echo "❌ Method 2: Failed to build binary"
fi

# Clean up failed attempt
cd "$PROJECT_ROOT"
rm -rf "$BUILD_DIR"

echo ""
echo "❌ All methods failed. Manual solutions:"
echo ""
echo "Option A: Disable App Sandbox"
echo "- Set com.apple.security.app-sandbox to false in BitStream.entitlements"
echo "- Download regular yt-dlp binary manually"
echo ""
echo "Option B: Use system yt-dlp"
echo "- Install yt-dlp system-wide: brew install yt-dlp"
echo "- Modify app to use /opt/homebrew/bin/yt-dlp or /usr/local/bin/yt-dlp"
echo ""
echo "Option C: Manual PyInstaller build"
echo "- Follow the PyInstaller steps manually"
echo "- Debug any issues with the standalone build"

exit 1
