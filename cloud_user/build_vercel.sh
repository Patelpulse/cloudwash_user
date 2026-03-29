#!/bin/bash

set -e

if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

export PATH="$PWD/flutter/bin:$PATH"
flutter doctor -v
flutter pub get
flutter build web --release
