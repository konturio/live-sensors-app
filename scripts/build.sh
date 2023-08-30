#!/bin/bash

version=$(git tag | tail -1)
flutter build apk
cp ./build/app/outputs/flutter-apk/app-release.apk ./releases/live-sensors-${version}-release.apk
