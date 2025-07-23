#!/bin/bash

# GameNetworkingSockets Unity Build Script
# This script builds the library and extracts files needed for Unity

set -e

echo "🚀 Building GameNetworkingSockets for Unity with OpenSSL 1.1.1b + protobuf v21.9..."

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

# Check what libraries are needed
echo ""
echo "🔍 Checking library dependencies..."
echo "Your built library depends on these libraries:"
docker run --platform linux/amd64 --rm gamenetworkingsockets-build ldd /output/libGameNetworkingSockets.so

echo ""
echo "✅ Build complete! Files are in ./unity-build/"
echo ""
echo "📋 For Unity deployment:"
echo "1. Copy unity-build/libGameNetworkingSockets.so to your Unity project's Plugins/Linux/x86_64/ folder"
echo "2. See the OpenSSL 1.1.1b deployment options below:"
echo ""
echo "🔧 OpenSSL 1.1.1b Deployment Options:"
echo ""
echo "Option 1 - Bundle OpenSSL 1.1.1b libraries (recommended):"
echo "  - Extract OpenSSL 1.1.1b .so files from the container"
echo "  - Place them alongside your GameNetworkingSockets library"
echo "  - More predictable than relying on system OpenSSL"
echo ""
echo "Option 2 - Use system OpenSSL (if compatible):"
echo "  - Most modern Linux systems have OpenSSL 1.1.1 or 3.x"
echo "  - May work but version differences could cause issues"
echo ""

# Cleanup
docker rm $CONTAINER_ID

echo "🎉 Done! Check the unity-build/ directory." 