FROM ubuntu:jammy

RUN apt update && \
    apt install -y cmake build-essential autoconf automake libtool curl make unzip && \
    cd /tmp && curl -OL https://github.com/protocolbuffers/protobuf/releases/download/v21.9/protobuf-cpp-3.21.9.tar.gz && \
    tar -xzf protobuf-cpp-3.21.9.tar.gz && cd protobuf-3.21.9 && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=ON -Dprotobuf_BUILD_SHARED_LIBS=ON -Dprotobuf_BUILD_TESTS=OFF -B build && \
    cmake --build build --parallel 4 && cmake --install build && cd /tmp && \
    curl -OL https://www.openssl.org/source/openssl-1.1.1b.tar.gz && tar -zxf openssl-1.1.1b.tar.gz && cd openssl-1.1.1b && \
    ./config && make -j4 && make install && cd && \
    rm -rf /tmp && rm -rf /var/lib/apt/lists/* && ldconfig

WORKDIR /build
COPY . .

# Build using CMake
RUN mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=MinSizeRel && \
    make -j4

# Create output directory and copy files
RUN mkdir -p /output && \
    cp build/src/libGameNetworkingSockets.so /output/ && \
    cp -r examples /output/ && \
    cp -r include /output/

# Create a script to show build info
RUN echo '#!/bin/bash\n\
echo "GameNetworkingSockets built successfully!"\n\
echo "OpenSSL 1.1.1b + protobuf v21.9 + CMake on ubuntu:jammy"\n\
echo ""\n\
echo "Library dependencies:"\n\
ldd /output/libGameNetworkingSockets.so\n\
echo ""\n\
echo "To copy files to host:"\n\
echo "docker cp <container_id>:/output ./unity-build"\n\
' > /output/info.sh && chmod +x /output/info.sh

WORKDIR /output
CMD ["/output/info.sh"]
