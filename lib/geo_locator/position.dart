import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../logger/logger.dart';
import 'package:flutter/foundation.dart';

Future<Position> requestLocationPermission() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.best,
  );
}

class GeoLocatorError extends Error {
  final String message;
  GeoLocatorError(this.message);
}

class GeoLocatorController {
  final Logger logger = Logger();
  late StreamController<Position> _streamController;
  late Stream<Position> stream;
  late LocationSettings locationSettings;
  // StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;

  GeoLocatorController() {
    _streamController =
        StreamController<Position>(onListen: _initTrackPosition);
    stream = _streamController.stream.asBroadcastStream();
  }

  Future<String> getStats() async {
    LocationAccuracyStatus accuracy = await Geolocator.getLocationAccuracy();
    return 'Accuracy: $accuracy';
  }

  _initTrackPosition() async {
    try {
      _serviceStatusStreamSubscription =
          Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
       logger.info("Geolocator service status changed to $status");
      });
    } catch (e) {
      logger
          .error("Attempt to subscribe to service status subscription failed");
    }
    try {
      logger.info("Requesting permissions");
      Position position = await requestLocationPermission();
      logger.info("Permission granted");
      logger.info("Initial position: ${position.toString()}");
      logger.info("Create position stream");
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          locationSettings = AndroidSettings(
              accuracy: LocationAccuracy.best,
              // distanceFilter: 100,
              // forceLocationManager: true,
              intervalDuration: const Duration(seconds: 1),
              //(Optional) Set foreground notification config to keep the app alive
              //when going to the background
              foregroundNotificationConfig: const ForegroundNotificationConfig(
                notificationText:
                    "App keep tracking user location in background",
                notificationTitle: "Live Sensors tracker",
                enableWakeLock: true,
              ));
          break;

        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          locationSettings = AppleSettings(
            accuracy: LocationAccuracy.high,
            activityType: ActivityType.fitness,
            // distanceFilter: 100,
            pauseLocationUpdatesAutomatically: true,
            // Only set to true if our app will be started up in the background.
            showBackgroundLocationIndicator: false,
          );
        default:
          locationSettings = const LocationSettings(
            accuracy: LocationAccuracy.high,
            // distanceFilter: 100,
          );
      }

      Stream<Position> positionStream =
          Geolocator.getPositionStream(locationSettings: locationSettings);
      positionStream.pipe(_streamController);
    } catch (error) {
      logger.error(error.toString());
      _streamController.addError(GeoLocatorError("Unknown"));
      _streamController.close();
    }
  }
}
