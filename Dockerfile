# Multi-stage build for GameNetworkingSockets
# Stage 1: Build environment
FROM ubuntu:jammy AS builder

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies and tools for building protobuf and OpenSSL from source
RUN apt-get update && apt-get install -y \
    build-essential \
    meson \
    ninja-build \
    pkg-config \
    wget \
    unzip \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# Build OpenSSL 1.1.1b from source
RUN cd /tmp \
 && wget https://www.openssl.org/source/old/1.1.1/openssl-1.1.1b.tar.gz \
 && tar -zxf openssl-1.1.1b.tar.gz \
 && cd openssl-1.1.1b \
 && ./config \
 && make -j4 \
 && make install \
 && cd .. \
 && rm -rf * \
 && ldconfig

# Build protobuf v21.9 from source
RUN cd /tmp && \
    wget https://github.com/protocolbuffers/protobuf/releases/download/v21.9/protobuf-cpp-3.21.9.tar.gz && \
    tar -xzf protobuf-cpp-3.21.9.tar.gz && \
    cd protobuf-3.21.9 && \
    cmake -Dprotobuf_BUILD_TESTS=OFF \
          -Dprotobuf_BUILD_SHARED_LIBS=ON \
          -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
          -DCMAKE_BUILD_TYPE=MinSizeRel \
          -B build && \
    cmake --build build --parallel 4 && \
    cmake --install build && \
    cd / && rm -rf /tmp/protobuf* && \
    ldconfig

# Set working directory
WORKDIR /build

# Copy source code
COPY . .

# Build using Meson (better Ubuntu protobuf compatibility)
RUN meson setup build --buildtype=minsize --default-library=shared

# Build the library
RUN meson compile -C build

# Stage 2: Extract runtime libraries
FROM ubuntu:jammy AS runtime

# Install minimal runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy OpenSSL 1.1.1b and protobuf v21.9 libraries from builder
COPY --from=builder /usr/local/lib/libssl.so* /usr/local/lib/
COPY --from=builder /usr/local/lib/libcrypto.so* /usr/local/lib/
COPY --from=builder /usr/local/lib/libprotobuf.so* /usr/local/lib/
RUN ldconfig

# Copy built libraries
COPY --from=builder /build/build/src/libGameNetworkingSockets.so /output/
COPY --from=builder /build/examples /output/examples/
COPY --from=builder /build/include /output/include/

# Create a script to copy dependencies
RUN echo '#!/bin/bash\n\
echo "GameNetworkingSockets built successfully with OpenSSL 1.1.1b + protobuf v21.9!"\n\
echo ""\n\
echo "For Unity deployment, you need these files:"\n\
echo "- /output/libGameNetworkingSockets.so (main library)"\n\
echo "- OpenSSL 1.1.1b libraries (see below)"\n\
echo ""\n\
echo "Library dependencies:"\n\
ldd /output/libGameNetworkingSockets.so\n\
echo ""\n\
echo "To copy all files to host:"\n\
echo "docker cp <container_id>:/output ./gamenetworkingsockets-build"\n\
' > /output/info.sh && chmod +x /output/info.sh

WORKDIR /output
CMD ["/output/info.sh"]
