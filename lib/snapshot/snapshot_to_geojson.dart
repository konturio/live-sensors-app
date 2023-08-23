
import 'package:turf/turf.dart' as Turf;
import 'package:live_sensors/geolocator/position.dart' as Locator;
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

Turf.Position toGeoJsonPosition(Locator.Position pos) {
  return Turf.Position(pos.longitude, pos.latitude, pos.altitude);
}

precise(double val) {
  return val.toStringAsPrecision(precision);
}

preciseAll(List<double> list) {
  return list.map((v) => v.toStringAsPrecision(precision)).toList();
}

const precision = 3;
Turf.FeatureCollection snapshotToGeoJson(Snapshot snapshot) {
  Locator.Position? position = snapshot.position;
  if (position == null) {
    throw ConversionError('Missing coordinates in snapshot');
  }
  Turf.Feature<Turf.Point> point = Turf.Feature<Turf.Point>(
    id: customNanoId(),
    geometry: Turf.Point(coordinates: toGeoJsonPosition(position)),
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

  return Turf.FeatureCollection(features: [point]);
}
