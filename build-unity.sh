#!/bin/bash

# GameNetworkingSockets Unity Build Script
# This script builds the library and extracts files needed for Unity

set -e

echo "🚀 Building GameNetworkingSockets (.so) for Unity..."
echo "OpenSSL 1.1.1b + protobuf 3.7.0 (BOTH STATICALLY LINKED) + CMake + ubuntu:jammy"

# Build the Docker image
echo "📦 Building Docker image..."
docker build --platform linux/amd64 -t gamenetworkingsockets-build .

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

echo ""
echo "✅ Build complete! Files are in ./unity-build/"
echo "📋 Main file: unity-build/libGameNetworkingSockets.so"

# Cleanup
docker rm $CONTAINER_ID

echo "🎉 Done! Check unity-build/libGameNetworkingSockets.so" 