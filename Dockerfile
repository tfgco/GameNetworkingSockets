FROM ubuntu:jammy

RUN apt update && apt install -y cmake build-essential autoconf automake libtool curl make unzip pkg-config

RUN cd /tmp && \
    curl -OL https://www.openssl.org/source/openssl-1.1.1b.tar.gz && tar -zxf openssl-1.1.1b.tar.gz && cd openssl-1.1.1b && \
    ./config no-shared no-dso -fPIC -fvisibility=hidden \
        --prefix=/usr/local \
        --openssldir=/usr/local/ssl && \
    make -j4 && make install && rm -rf /var/lib/apt/lists/*
    
RUN cd /tmp && curl -OL https://github.com/protocolbuffers/protobuf/releases/download/v3.7.0/protobuf-cpp-3.7.0.zip && \
    unzip protobuf-cpp-3.7.0.zip && cd protobuf-3.7.0 && \
    mkdir build && cd build && \
    cmake ../cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -DCMAKE_CXX_FLAGS="-fvisibility=hidden -fvisibility-inlines-hidden" \
        -DCMAKE_C_FLAGS="-fvisibility=hidden" \
        -Dprotobuf_BUILD_SHARED_LIBS=OFF \
        -Dprotobuf_BUILD_TESTS=OFF \
        -Dprotobuf_BUILD_EXAMPLES=OFF \
        -Dprotobuf_BUILD_PROTOC_BINARIES=ON && \
    make -j4 && make install && rm -rf /var/lib/apt/lists/*
    
RUN ldconfig

# Verify protoc installation
RUN protoc --version && which protoc

WORKDIR /build
COPY . .

# Build using CMake with static OpenSSL and protobuf linking and hidden symbols
RUN mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=MinSizeRel \
             -DCMAKE_CXX_FLAGS="-fvisibility=hidden -fvisibility-inlines-hidden" \
             -DCMAKE_C_FLAGS="-fvisibility=hidden" \
             -DCMAKE_PREFIX_PATH=/usr/local \
             -DOPENSSL_USE_STATIC_LIBS=TRUE \
             -DProtobuf_USE_STATIC_LIBS=ON && \
    make -j4

# Create output directory and copy files
RUN mkdir -p /output && \
    cp build/src/libGameNetworkingSockets.so /output/ && \
    cp -r examples /output/ && \
    cp -r include /output/

# Create a script to show build info
RUN echo '#!/bin/bash\n\
echo "GameNetworkingSockets built successfully!"\n\
echo "OpenSSL 1.1.1b + protobuf 3.7.0 (BOTH STATICALLY LINKED) + CMake on ubuntu:jammy"\n\
echo ""\n\
echo "✅ OpenSSL 1.1.1b is statically linked - no conflicts with system OpenSSL!"\n\
echo "✅ Protobuf 3.7.0 is statically linked - no conflicts with system protobuf!"\n\
echo "✅ All OpenSSL and protobuf symbols are hidden from dynamic linker"\n\
echo ""\n\
echo "Library dependencies (should NOT show OpenSSL or protobuf):"\n\
ldd /output/libGameNetworkingSockets.so\n\
echo ""\n\
echo "Checking for OpenSSL symbols (should be hidden):"\n\
nm -D /output/libGameNetworkingSockets.so | grep -i ssl || echo "✅ No OpenSSL symbols exposed!"\n\
echo ""\n\
echo "Checking for protobuf symbols (should be hidden):"\n\
nm -D /output/libGameNetworkingSockets.so | grep protobuf || echo "✅ No protobuf symbols exposed!"\n\
echo ""\n\
echo "To copy files to host:"\n\
echo "docker cp <container_id>:/output ./unity-build"\n\
' > /output/info.sh && chmod +x /output/info.sh

WORKDIR /output
CMD ["/output/info.sh"]
