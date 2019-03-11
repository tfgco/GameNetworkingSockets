from ubuntu

RUN apt update && \
    apt install -y cmake build-essential autoconf automake libtool curl make unzip && \
    cd /tmp && curl -OL https://github.com/protocolbuffers/protobuf/releases/download/v3.7.0/protobuf-cpp-3.7.0.zip && \
    unzip protobuf-cpp-3.7.0.zip && cd protobuf-3.7.0 && ./configure CFLAGS=-fPIC CXXFLAGS=-fPIC --enable-shared && make -j4 && make install && cd /tmp && \
    curl -OL https://www.openssl.org/source/openssl-1.1.1b.tar.gz && tar -zxf openssl-1.1.1b.tar.gz && cd openssl-1.1.1b && \
    ./config && make -j4 && make install && cd && \
    rm -rf /tmp && rm -rf /var/lib/apt/lists/* && ldconfig
