import 'dart:async';
import 'package:geolocator/geolocator.dart';

import 'logger.dart';

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
  return await Geolocator.getCurrentPosition();
}

class GeoLocatorError extends Error {
  final String message;
  GeoLocatorError(this.message);
}

class GeoLocator {
  final Logger logger;
  late StreamController<Position> _streamController;
  late Stream<Position> stream;
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;

  GeoLocator({required this.logger}) {
    _streamController =
        StreamController<Position>(onListen: _initTrackPosition);
    stream = _streamController.stream;
  }

  _initTrackPosition() async {
    try {
      logger.info("Requesting permissions");
      Position position = await requestLocationPermission();
      logger.info("Permission granted");
      logger.info("Initial position: ${position.toString()}");
      logger.info("Create position stream");
      // TODO: log service status messages status too
      Stream<Position> positionStream = Geolocator.getPositionStream();
      positionStream.pipe(_streamController);
    } catch (error) {
      logger.error(error.toString());
      _streamController.addError(GeoLocatorError("Unknown"));
      _streamController.close();
    }
  }
}
