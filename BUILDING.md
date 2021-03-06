Building
---

### Dependencies

* CMake or Meson, and build tool like Ninja, GNU Make or Visual Studio
* A C++11-compliant compiler, such as:
  * GCC 7.3 or later
  * Clang 3.3 or later
  * Visual Studio 2017 or later
* One of the following crypto solutions:
  * OpenSSL 1.1.1 or later
  * OpenSSL 1.1.x, plus ed25519-donna and curve25519-donna.  (We've made some
    minor changes, so the source is included in this project.)
  * [bcrypt](https://docs.microsoft.com/en-us/windows/desktop/api/bcrypt/) (windows only)
* Google protobuf 2.6.1+


#### OpenSSL
If you're building on Linux or Mac, just install the appropriate packages from
your package manager.

Ubuntu/Debian:
```
# apt install libssl-dev
```

Arch Linux:
```
# pacman -S openssl
```

Mac OS X, using [Homebrew](https://brew.sh):
```
$ brew install openssl
$ export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/opt/openssl/lib/pkgconfig
```
GameNetworkingSockets requries openssl version 1.1+, so if you install and link openssl but at compile you see the error ```Dependency libcrypto found: NO (tried cmake and framework)``` you'll need to force Brew to install openssl 1.1. You can do that like this:
```
$ brew install openssl@1.1
$ export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/opt/openssl@1.1/lib/pkgconfig
```

For MSYS2, see the [MSYS2](#msys2) section. There are packages available in
the MinGW repositories for i686 and x86_64.

For Visual Studio, you can install the [OpenSSL
binaries](https://slproweb.com/products/Win32OpenSSL.html) provided by Shining
Light Productions. The Windows CMake distribution understands how to find the
OpenSSL binaries from these installers, which makes building a lot easier. Be
sure to pick the installers **without** the "Light"suffix. In this instance,
"Light" means no development libraries or headers.


#### protobuf

If you're building on Linux or Mac, just install the appropriate packages from
your package manager.

Ubuntu/Debian:
```
# apt install libprotobuf-dev protobuf-compiler
```

Arch Linux:
```
# pacman -S protobuf
```

Mac OS X, using [Homebrew](https://brew.sh):
```
$ brew install protobuf
```

For MSYS2, see the [MSYS2](#msys2) section. There are packages available in
the MinGW repositories for i686 and x86_64.

For Visual Studio, the process is a bit more involved, as you need to compile
protobuf yourself. The process we used is something like this:

```
C:\dev> git clone https://github.com/google/protobuf
C:\dev> cd protobuf
C:\dev\protobuf> git checkout -t origin/3.5.x
C:\dev\protobuf> mkdir cmake_build
C:\dev\protobuf> cd cmake_build
C:\dev\protobuf\cmake_build> vcvarsall amd64
C:\dev\protobuf\cmake_build> cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -Dprotobuf_BUILD_TESTS=OFF -Dprotobuf_BUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=c:\sdk\protobuf-amd64 ..\cmake
C:\dev\protobuf\cmake_build> ninja
C:\dev\protobuf\cmake_build> ninja install
```


### Linux

If you already have the dependencies installed (see above sections), then you
should be able to build fairly trivially.

Using Meson:

```
$ meson . build
$ ninja -C build
```

Or CMake:

```
$ mkdir build
$ cd build
$ cmake -G Ninja -DProtobuf_USE_STATIC_LIBS=on -DCMAKE_BUILD_TYPE=MinSizeRel ../
$ ninja
```

### Mac OS
```
$ mkdir build-osx
$ cd build-osx
$ cmake -G Ninja -DProtobuf_USE_STATIC_LIBS=on -DCMAKE_BUILD_TYPE=MinSizeRel ../
```

### Android
Set TFG_PREBUILT_REPO_DIR to the dir where you cloned https://github.com/tfgco/pre-built-public-libs and NDK_DIR and then run:
```
$ mkdir build-android
$ cd build-android
$ cmake . ../ -DProtobuf_INCLUDE_DIR=$TFG_PREBUILT_REPO_DIR/android/armv7-a/libprotobuf/3.7.0/ -DProtobuf_LITE_LIBRARY=$TFG_PREBUILT_REPO_DIR/android/armv7-a/libprotobuf/3.7.0/libprotobuf-lite.a -DProtobuf_LIBRARIES=$TFG_PREBUILT_REPO_DIR/android/armv7-a/libprotobuf/3.7.0/ -DCMAKE_TOOLCHAIN_FILE=$NDK_DIR/build/cmake/android.toolchain.cmake -DOPENSSL_CRYPTO_LIBRARY=$TFG_PREBUILT_REPO_DIR/android/armv7-a/openssl/1.1.1b/libcrypto.a -DOPENSSL_INCLUDE_DIR=$TFG_PREBUILT_REPO_DIR/android/armv7-a/openssl/1.1.1b/include -DCMAKE_SYSTEM_NAME=Android -DUSE_BCRYPT=off -DOPENSSL_HAS_25519_RAW=on -DCMAKE_CXX_FLAGS="-fPIC" -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_ANDROID_ARCH_ABI=armeabi-v7a -GNinja
```

for 64bit builds use: -DCMAKE_ANDROID_ARCH_ABI=arm64-v8a -DCMAKE_SYSTEM_VERSION=21 -DANDROID_ABI=arm64-v8a -DANDROID_PLATFORM=android-21

### iOS
Set TFG_PREBUILT_REPO_DIR to the dir where you cloned https://github.com/tfgco/pre-built-public-libs and then run:
```
$ mkdir build-ios
$ cd build-ios
$ OPENSSL_ROOT_DIR=$TFG_PREBUILT_REPO_DIR/ios/openssl/1.1.1b/ cmake ../ -DProtobuf_LITE_LIBRARY=$TFG_PREBUILT_REPO_DIR/ios/protobuf/3.7.0/lib/libprotobuf-lite.a -DProtobuf_LIBRARIES=$TFG_PREBUILT_REPO_DIR/ios/protobuf/3.7.0/lib -DCMAKE_TOOLCHAIN_FILE=$TFG_PREBUILT_REPO_DIR/ios.toolchain.cmake -DIOS_PLATFORM=OS -DProtobuf_INCLUDE_DIR=$TFG_PREBUILT_REPO_DIR/ios/protobuf/3.7.0/include -DOPENSSL_INCLUDE_DIR=$TFG_PREBUILT_REPO_DIR/ios/openssl/1.1.1b/include -DOPENSSL_CRYPTO_LIBRARY=$TFG_PREBUILT_REPO_DIR/ios/openssl/1.1.1b/libcrypto.a -DUSE_BCRYPT=false -DENABLE_BITCODE=false -DCMAKE_BUILD_TYPE=MinSizeRel
```

### MSYS2

You can also build this project on [MSYS2](https://www.msys2.org). First,
follow the [instructions](https://github.com/msys2/msys2/wiki/MSYS2-installation) on the
MSYS2 website for updating your MSYS2 install.

**Be sure to follow the instructions at the site above to update MSYS2 before
you continue. A fresh install is *not* up to date by default.**

Next install the dependencies for building GameNetworkingSockets (if you want
a 32-bit build, install the i686 versions of these packages):

```
$ pacman -S \
    git \
    mingw-w64-x86_64-gcc \
    mingw-w64-x86_64-meson \
    mingw-w64-x86_64-openssl \
    mingw-w64-x86_64-pkg-config \
    mingw-w64-x86_64-protobuf
```

And finally, clone the repository and build it:

```
$ git clone https://github.com/ValveSoftware/GameNetworkingSockets.git
$ cd GameNetworkingSockets
$ meson . build
$ ninja -C build
```

**NOTE:** When building with MSYS2, be sure you launch the correct version of
the MSYS2 terminal, as the three different Start menu entries will give you
different environment variables that will affect the build.  You should run the
Start menu item named `MSYS2 MinGW 64-bit` or `MSYS2 MinGW 32-bit`, depending
on the packages you've installed and what architecture you want to build
GameNetworkingSockets for.


### Visual Studio

When configuring GameNetworkingSockets using CMake, you need to add the
protobuf `bin` directory to your path in order to help CMake figure out the
protobuf installation prefix:
```
C:\dev\GameNetworkingSockets> mkdir build
C:\dev\GameNetworkingSockets> cd build
C:\dev\GameNetworkingSockets\build> set PATH=%PATH%;C:\sdk\protobuf-amd64\bin
C:\dev\GameNetworkingSockets\build> vcvarsall amd64
C:\dev\GameNetworkingSockets\build> cmake -G Ninja ..
C:\dev\GameNetworkingSockets\build> ninja
```

### Visual Studio Code
If you're using Visual Studio Code, we have a few extensions to recommend
installing, which will help build the project. Once you have these extensions
installed, open up the .code-workspace file in Visual Studio Code.

#### C/C++ by Microsoft
This extension provides IntelliSense support for C/C++.

VS Marketplace Link: https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools

#### CMake Tools by vector-of-bool
This extension allows for configuring the CMake project and building it from
within the Visual Studio Code IDE.

VS Marketplace Link: https://marketplace.visualstudio.com/items?itemName=vector-of-bool.cmake-tools

#### Meson by Ali Sabil
This extension comes in handy if you're editing the Meson build files.

VS Marketplace Link: https://marketplace.visualstudio.com/items?itemName=asabil.meson

