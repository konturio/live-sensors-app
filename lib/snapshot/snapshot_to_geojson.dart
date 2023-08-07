// https://github.com/konturio/disaster-ninja-fe/blob/bc3e362525ac939b8513ac4bcc9f80dc5df965dd/src/features/live_sensor/toSnapshotFormat.ts

import 'package:turf/turf.dart';
// import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:geolocator/geolocator.dart' as locator;
import 'package:nanoid/nanoid.dart';
import './snapshot.dart';

String customNanoId() {
  return customAlphabet(
    '0123456789_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
    22,
  );
}

class ConversionError extends Error {
  final String message;
  ConversionError(this.message);
}

Position toGeoJsonPosition(locator.Position pos) {
  return Position(pos.longitude, pos.latitude, pos.altitude);
}

precise(double val) {
  return val.toStringAsPrecision(precision);
}

preciseAll(List<double> list) {
  return list.map((v) => v.toStringAsPrecision(precision)).toList();
}

const precision = 3;
FeatureCollection snapshotToGeoJson(Snapshot snapshot) {
  locator.Position? position = snapshot.position;
  if (position == null) {
    throw ConversionError('Missing coordinates in snapshot');
  }
  Feature<Point> point = Feature<Point>(
    id: customNanoId(),
    geometry: Point(coordinates: toGeoJsonPosition(position)),
    properties: {
      'lng': precise(position.longitude),
      'lat': precise(position.latitude),
      'alt': precise(position.altitude),
      'accuracy': precise(position.accuracy),
      'speed': precise(position.speed),
      'speedAccuracy': precise(position.speedAccuracy),
      'heading': precise(position.heading),
      'coordTimestamp': position.timestamp?.millisecondsSinceEpoch,
      'coordSystTimestamp': position.timestamp?.millisecondsSinceEpoch,
      'userAgent': snapshot.userAgent,
      'orientX': preciseAll(snapshot.magnetometer.x),
      'orientY': preciseAll(snapshot.magnetometer.y),
      'orientZ': preciseAll(snapshot.magnetometer.z),
      'orientTime':
          snapshot.magnetometer.timestamp.map((t) => t.millisecondsSinceEpoch).toList(),
      'accelX': preciseAll(snapshot.accelerometer.x),
      'accelY': preciseAll(snapshot.accelerometer.y),
      'accelZ': preciseAll(snapshot.accelerometer.z),
      'accelTime':
          snapshot.accelerometer.timestamp.map((t) => t.millisecondsSinceEpoch).toList(),
      'gyroX': preciseAll(snapshot.gyroscope.x),
      'gyroY': preciseAll(snapshot.gyroscope.y),
      'gyroZ': preciseAll(snapshot.gyroscope.z),
      'gyroTime':
          snapshot.gyroscope.timestamp.map((t) => t.millisecondsSinceEpoch).toList(),
    },
  );

  return FeatureCollection(features: [point]);
}
