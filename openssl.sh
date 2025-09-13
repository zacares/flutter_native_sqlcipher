./Configure android-x86_64 \
  -D__ANDROID_API__=$API_LEVEL \
  --prefix=$(pwd)/install \
  -DANDROID_NDK_ROOT=$ANDROID_NDK_ROOT

build_for_abi "armeabi-v7a" "android-arm"
build_for_abi "arm64-v8a" "android-arm64"
build_for_abi "x86" "android-x86"
build_for_abi "x86_64" "android-x86_64"