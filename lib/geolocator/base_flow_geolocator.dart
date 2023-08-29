import 'dart:async';
import 'package:geolocator/geolocator.dart' as BaseFlow;
import 'geolocator.dart';
import '../logger/logger.dart';
import 'package:flutter/foundation.dart';

import 'position.dart';

Future<BaseFlow.Position> requestLocationPermission() async {
  bool serviceEnabled;
  BaseFlow.LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await BaseFlow.Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await BaseFlow.Geolocator.checkPermission();
  if (permission == BaseFlow.LocationPermission.denied) {
    permission = await BaseFlow.Geolocator.requestPermission();
    if (permission == BaseFlow.LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == BaseFlow.LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await BaseFlow.Geolocator.getCurrentPosition(
    desiredAccuracy: BaseFlow.LocationAccuracy.gpsOnly,
  );
}

class GeoLocatorError extends Error {
  final String message;
  GeoLocatorError(this.message);
}

class BaseFlowGeolocator implements GeoLocator {
  final Logger _logger = Logger();
  // late StreamController<BaseFlow.Position> _positionStreamController;
  late Stream<BaseFlow.Position> _positionStream;
  // StreamSubscription<Position>? _positionStreamSubscription;
  // late StreamController<BaseFlow.ServiceStatus> _statusStreamController;
  late Stream<BaseFlow.ServiceStatus> _statusStream;
  // StreamSubscription<BaseFlow.ServiceStatus>? _serviceStatusStreamSubscription;
  late BaseFlow.LocationSettings _locationSettings;

  @override
  final LocationAccuracy desiredAccuracy;

  @override
  final int duration;

  BaseFlowGeolocator(
      {this.duration = 1, this.desiredAccuracy = LocationAccuracy.best});

  @override
  requestPermissions() async {
    _logger.info("Requesting permissions");
    BaseFlow.Position position = await requestLocationPermission();
    _logger.info("Permission granted");
    _logger.info("Initial position: ${position.toString()}");
    _logger.info("Create position stream");
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        _locationSettings = BaseFlow.AndroidSettings(
            accuracy: BaseFlow.LocationAccuracy.gpsOnly,
            // distanceFilter: 100,
            intervalDuration: const Duration(seconds: 1),
            // avoid FusedLocationProviderClient
            forceLocationManager: true,
            //(Optional) Set foreground notification config to keep the app alive
            //when going to the background
            foregroundNotificationConfig:
                const BaseFlow.ForegroundNotificationConfig(
              notificationText: "App keep tracking user location in background",
              notificationTitle: "Live Sensors tracker",
              enableWakeLock: true,
              enableWifiLock: true,
            ));
        break;

      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        _locationSettings = BaseFlow.AppleSettings(
          accuracy: BaseFlow.LocationAccuracy.high,
          activityType: BaseFlow.ActivityType.fitness,
          // distanceFilter: 100,
          pauseLocationUpdatesAutomatically: true,
          // Only set to true if our app will be started up in the background.
          showBackgroundLocationIndicator: false,
        );
      default:
        _locationSettings = const BaseFlow.LocationSettings(
          accuracy: BaseFlow.LocationAccuracy.high,
          // distanceFilter: 100,
        );
    }
  }

  @override
  Future<String> getAccuracy() async {
    BaseFlow.LocationAccuracyStatus accuracy =
        await BaseFlow.Geolocator.getLocationAccuracy();
    return accuracy.toString();
  }

  @override
  Stream<Position> getPositionStream() {
    _connectToPositionStream();
    return _positionStream.map((event) => Position(
          longitude: event.longitude,
          latitude: event.latitude,
          timestamp: event.timestamp,
          accuracy: event.accuracy,
          altitude: event.altitude,
          heading: event.heading,
          speed: event.speed,
          speedAccuracy: event.speedAccuracy,
          floor: event.floor,
          isMocked: event.isMocked,
        ));
  }

  @override
  Stream<GeoLocationStatus> getStatusStream() {
    _connectToStatusStream();
    return _statusStream.map((event) {
      switch (event) {
        case BaseFlow.ServiceStatus.enabled:
          return GeoLocationStatus.enabled;
        case BaseFlow.ServiceStatus.disabled:
          return GeoLocationStatus.disabled;
        default:
          _logger.warn(
              'Unknown GeoLocationStatus in BaseFlow.ServiceStatus: $event');
          return GeoLocationStatus.disabled;
      }
    });
  }

  bool _positionStreamConnected = false;
  _connectToPositionStream() {
    if (!_positionStreamConnected) {
      _positionStream = BaseFlow.Geolocator.getPositionStream(
        locationSettings: _locationSettings,
      );
      // positionStream.pipe(_positionStreamController);
      _positionStreamConnected = true;
    }
  }

  bool _statusStreamConnected = false;
  _connectToStatusStream() {
    if (!_statusStreamConnected) {
      _statusStream = BaseFlow.Geolocator.getServiceStatusStream();
      // statusStream.pipe(_statusStreamController);
      _statusStreamConnected = true;
    }
  }
}
