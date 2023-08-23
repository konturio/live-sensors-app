import 'package:live_sensors/geolocator/position.dart';
import 'package:live_sensors/snapshot/measurement.dart';
import 'package:live_sensors/entities/user.dart';
import 'package:uuid/uuid.dart';
import 'snapnshot_error.dart';


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

  factory MeasurementsTable.init() {
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

  @override
  String toString() {
    return 'x: $x\n'
    'y: $y\n'
    'z: $z\n'
    'timestamp: $timestamp';
  }
}

class Snapshot {
  final String id;
  final User user;
  final DateTime startDateTime;
  final MeasurementsTable accelerometer;
  final MeasurementsTable gyroscope;
  final MeasurementsTable magnetometer;
  final String userAgent;

  SnapshotError? error;
  late DateTime? endDateTime;
  late Position? position;

  bool _sealed = false;

  Snapshot({
    required this.user,
    required this.id,
    required this.startDateTime,
    required this.accelerometer,
    required this.gyroscope,
    required this.magnetometer,
    required this.userAgent,
    this.endDateTime,
    this.error,
    this.position,
  });

  factory Snapshot.init(User usr, String usrA) {
    return Snapshot(
      user: usr,
      userAgent: usrA,
      id: const Uuid().v4(),
      startDateTime: DateTime.now(),
      accelerometer: MeasurementsTable.init(),
      gyroscope: MeasurementsTable.init(),
      magnetometer: MeasurementsTable.init(),
    );
  }

  seal(Position pos) {
    position = pos;
    endDateTime = DateTime.now();
    _sealed = true;
  }

  add(Measurement m) {
    if (_sealed) {
      throw Error();
    }
    accelerometer.add(m.$1.data.x, m.$1.data.y, m.$1.data.z, m.$1.timestamp);
    gyroscope.add(m.$2.data.x, m.$2.data.y, m.$2.data.z, m.$2.timestamp);
    magnetometer.add(m.$3.data.x, m.$3.data.y, m.$3.data.z, m.$3.timestamp);
  }

  factory Snapshot.fromJson(Map<String, dynamic> json) {
    User? usr = json['user'];
    DateTime? startDateTime = json['startDateTime'];
    String userAgent = json['userAgent'] ?? 'Unknown';

    if (usr == null || startDateTime == null) {
      throw ParsingError('Required properties missing');
    }

    Snapshot snap = Snapshot(
      user: usr,
      id: const Uuid().v4(),
      startDateTime: startDateTime,
      userAgent: userAgent,
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
        'userAgent': userAgent,
        'accelerometer': accelerometer.toJson(),
        'gyroscope': gyroscope.toJson(),
        'magnetometer': magnetometer.toJson(),
        'error': error?.toJson(),
      };

  @override
  String toString() {
    try {
      return 'Snapshot:\n'
      '- id: $id\n'
      '- user: ${user.id}\n'
      '- userAgent:\n$userAgent\n'
      '- error: $error\n'
      '- accelerometer: ${accelerometer.x.length} records\n'
      '- gyroscope: ${gyroscope.x.length} records\n'
      '- magnetometer: ${magnetometer.x.length} records\n'
      '- startDateTime: $startDateTime\n'
      '- endDateTime: $endDateTime\n';
    } catch (e) {
      print(e);
      return super.toString();
    }
  }
}
