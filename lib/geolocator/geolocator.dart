import 'position.dart';

/// Represent the possible location accuracy values.
enum LocationAccuracy {
  /// Location is accurate within a distance of 3000m on iOS and 500m on Android
  lowest,

  /// Location is accurate within a distance of 1000m on iOS and 500m on Android
  low,

  /// Location is accurate within a distance of 100m on iOS and between 100m and
  /// 500m on Android
  medium,

  /// Location is accurate within a distance of 10m on iOS and between 0m and
  /// 100m on Android
  high,

  /// Location is accurate within a distance of ~0m on iOS and between 0m and
  /// 100m on Android
  best,

  /// Location accuracy is optimized for navigation on iOS and matches the
  /// [LocationAccuracy.best] on Android
  bestForNavigation,

  /// Location accuracy is reduced for iOS 14+ devices, matches the
  /// [LocationAccuracy.lowest] on iOS 13 and below and all other platforms.
  reduced,
}

/// Describes the current state of the location service on the native platform.
enum GeoLocationStatus {
  /// Indicates that the location service on the native platform is disabled.
  disabled,

  /// Indicates that the location service on the native platform is enabled.
  enabled,
}

abstract class GeoLocator {
  final LocationAccuracy desiredAccuracy;
  final int duration;
  GeoLocator({this.duration = 1, this.desiredAccuracy = LocationAccuracy.best});

  Future<void> requestPermissions() async {
    throw UnimplementedError();
  }

  Future<String> getAccuracy() async {
    throw UnimplementedError();
  }

  Stream<Position> getPositionStream() {
    throw UnimplementedError();
  }

  Stream<GeoLocationStatus> getStatusStream() {
    throw UnimplementedError();
  }
}
