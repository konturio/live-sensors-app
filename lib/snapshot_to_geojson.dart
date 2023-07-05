// https://github.com/konturio/disaster-ninja-fe/blob/bc3e362525ac939b8513ac4bcc9f80dc5df965dd/src/features/live_sensor/toSnapshotFormat.ts

import 'package:turf/turf.dart';
import 'package:geolocator/geolocator.dart' as locator;
import './snapshot.dart';

class ConversionError extends Error {
  final String message;
  ConversionError(this.message);
}

Position toGeoJsonPosition(locator.Position pos) {
  return Position(pos.longitude, pos.latitude, pos.altitude);
}

FeatureCollection snapshotToGeoJson(Snapshot snapshot) {
  locator.Position? position = snapshot.position;
  if (position == null) {
    throw ConversionError('Missing coordinates in snapshot');
  }
  Feature<Point> point = Feature<Point>(
    geometry: Point(coordinates: toGeoJsonPosition(position)),
    properties: {},
  );

  return FeatureCollection(features: [point]);
}
