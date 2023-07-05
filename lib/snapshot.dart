import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'user.dart';
import 'snapnshot_error.dart';

import 'measurement.dart';

class ParsingError extends Error {
  final String message;
  ParsingError(this.message);
}

class MeasurementsTable {
  List<double> x;
  List<double> y;
  List<double> z;
  List<DateTime> timestamp;

  MeasurementsTable(this.x, this.y, this.z, this.timestamp);

  factory MeasurementsTable.empty() {
    return MeasurementsTable([], [], [], []);
  }

  factory MeasurementsTable.fromJson(Map<String, dynamic> json) {
    return MeasurementsTable(
        json['x'], json['y'], json['z'], json['timestamp']);
  }

  add(double x, double y, double z, DateTime timestamp) {
    this.x.add(x);
    this.y.add(y);
    this.z.add(z);
    this.timestamp.add(timestamp);
  }

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'z': z,
        'timestamp': timestamp,
      };
}

class Snapshot {
  final String id;
  final User user;
  final DateTime startDateTime;
  final MeasurementsTable accelerometer;
  final MeasurementsTable gyroscope;
  final MeasurementsTable magnetometer;
  SnapshotError? error;
  late DateTime? endDateTime;
  late Position? position;

  Snapshot({
    required this.user,
    required this.id,
    required this.startDateTime,
    required this.accelerometer,
    required this.gyroscope,
    required this.magnetometer,
    this.endDateTime,
    this.error,
    this.position,
  });

  factory Snapshot.empty(User u) {
    return Snapshot(
        user: u,
        id: Uuid().v4(),
        startDateTime: DateTime.now(),
        accelerometer: MeasurementsTable.empty(),
        gyroscope: MeasurementsTable.empty(),
        magnetometer: MeasurementsTable.empty());
  }

  seal(Position pos) {
    position = pos;
    endDateTime = DateTime.now();
  }

  add(Measurement m) {
    accelerometer.add(m.$1.data.x, m.$1.data.y, m.$1.data.z, m.$1.timestamp);
    gyroscope.add(m.$2.data.x, m.$2.data.y, m.$2.data.z, m.$2.timestamp);
    magnetometer.add(m.$3.data.x, m.$3.data.y, m.$3.data.z, m.$3.timestamp);
  }

  factory Snapshot.fromJson(Map<String, dynamic> json) {
    User? u = json['user'];
    DateTime? created = json['startDateTime'];

    if (u == null || created == null) {
      throw ParsingError('Required properties missing');
    }

    Snapshot snap = Snapshot(
      user: u,
      id: Uuid().v4(),
      startDateTime: created,
      accelerometer: MeasurementsTable.fromJson(json['accelerometer']),
      gyroscope: MeasurementsTable.fromJson(json['gyroscope']),
      magnetometer: MeasurementsTable.fromJson(json['magnetometer']),
    );

    if (json['error'] != null) {
      snap.error = SnapshotError.fromMap(json['error']);
    }

    if (json['position'] != null) {
      snap.position = Position.fromMap(json['position']);
    }

    if (json['endDateTime'] != null) {
      snap.endDateTime = json['endDateTime'];
    }

    return snap;
  }

  Map<String, dynamic> toJson() => {
        'startDateTime': startDateTime,
        'endDateTime': endDateTime,
        'position': position?.toJson(),
        'user': user.id,
        'accelerometer': accelerometer.toJson(),
        'gyroscope': gyroscope.toJson(),
        'magnetometer': magnetometer.toJson(),
        'error': error?.toJson(),
      };
}
