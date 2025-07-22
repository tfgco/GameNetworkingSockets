#!/bin/bash

# GameNetworkingSockets Unity Build Script
# This script builds the library and extracts files needed for Unity

set -e

echo "🚀 Building GameNetworkingSockets for Unity with protobuf v21.9..."

# Build the Docker image
echo "📦 Building Docker image..."
docker build --platform linux/amd64 --no-cache -t gamenetworkingsockets-build .

# Run the container and get the container ID
echo "🔨 Running build..."
CONTAINER_ID=$(docker run -d gamenetworkingsockets-build)

# Wait for the container to complete
docker wait $CONTAINER_ID

# Show the info
echo "ℹ️ Build completed! Here's what was built:"
docker logs $CONTAINER_ID

# Copy the files to the host
echo "📁 Copying files to ./unity-build/..."
mkdir -p unity-build
docker cp $CONTAINER_ID:/output/. unity-build/

# Check what OpenSSL libraries are needed
echo ""
echo "🔍 Checking OpenSSL dependencies..."
echo "Your built library depends on these libraries:"
docker run --platform linux/amd64 --rm gamenetworkingsockets-build ldd /output/libGameNetworkingSockets.so

echo ""
echo "✅ Build complete! Files are in ./unity-build/"
echo ""
echo "📋 For Unity deployment:"
echo "1. Copy unity-build/libGameNetworkingSockets.so to your Unity project's Plugins/Linux/x86_64/ folder"
echo "2. See the OpenSSL deployment options below:"
echo ""
echo "🔧 OpenSSL Deployment Options:"
echo ""
echo "Option 1 - Use system OpenSSL (recommended):"
echo "  - Most Linux systems have OpenSSL 3.x installed"
echo "  - Unity can use the system libraries automatically"
echo "  - No additional files needed"
echo ""
echo "Option 2 - Bundle OpenSSL libraries:"
echo "  - Extract OpenSSL .so files from the container"
echo "  - Place them alongside your GameNetworkingSockets library"
echo "  - Use: docker run --rm gamenetworkingsockets-build sh -c 'cp /usr/lib/x86_64-linux-gnu/libssl.so.3 /usr/lib/x86_64-linux-gnu/libcrypto.so.3 /output/' && docker cp \$CONTAINER_ID:/output/libssl.so.3 unity-build/ && docker cp \$CONTAINER_ID:/output/libcrypto.so.3 unity-build/"
echo ""
echo "Option 3 - Build with static OpenSSL:"
echo "  - Use: ./build-unity-static.sh (creates larger but self-contained .so)"
echo ""

# Cleanup
docker rm $CONTAINER_ID

echo "🎉 Done! Check the unity-build/ directory." 