export ANDROID_NDK_HOME=/Users/mac/Library/Android/sdk/ndk/25.2.9519653

export GOARCH=arm
export GOOS=android
export CGO_ENABLED=1
export CC=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64/bin/armv7a-linux-androideabi21-clang
go build -ldflags="-w -s" -buildmode=c-shared -o output/android/armeabi-v7a/libadd.so

echo "Build armeabi-v7a success"

export GOARCH=arm64
export GOOS=android
export CGO_ENABLED=1
export CC=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android21-clang
go build -ldflags="-w -s" -buildmode=c-shared -o output/android/arm64-v8a/libadd.so

echo "Build arm64-v8a success"
