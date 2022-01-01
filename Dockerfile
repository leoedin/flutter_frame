from cirrusci/flutter:2.8.1

# Note: Make sure the version is the same as the flutter-pi binaries
COPY . /app/
WORKDIR app

# Delete any old or local build stuff
RUN flutter clean

# Build the asset bundle
RUN flutter build bundle

# Build the app for release (taken from the flutter-pi readme)
RUN dart /sdks/flutter/bin/cache/dart-sdk/bin/snapshots/frontend_server.dart.snapshot \
  --sdk-root /sdks/flutter/bin/cache/artifacts/engine/common/flutter_patched_sdk_product \
  --target=flutter \
  --aot \
  --tfa \
  -Ddart.vm.product=true \
  --packages .packages \
  --output-dill build/kernel_snapshot.dill \
  --verbose \
  --depfile build/kernel_snapshot.d \
  package:flutter_frame/main.dart

# Install Flutter Engine Binaries
WORKDIR /
RUN git clone --depth 1 https://github.com/ardera/flutter-engine-binaries-for-arm.git engine-binaries

RUN ls /app/build
RUN ls /app/build/flutter_assets
# Generate the app.so release
RUN engine-binaries/arm/gen_snapshot_linux_x64_release \
  --deterministic \
  --snapshot_kind=app-aot-elf \
  --elf=/app/build/flutter_assets/app.so \
  --strip \
  --sim-use-hardfp \
  /app/build/kernel_snapshot.dill 

