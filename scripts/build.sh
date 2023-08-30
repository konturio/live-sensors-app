#!/bin/bash

version=$(git tag | grep -E '^[0-9]' | sort -V | tail -1)
flutter build apk
cp ./build/app/outputs/flutter-apk/app-release.apk ./releases/live-sensors-${version}-release.apk
