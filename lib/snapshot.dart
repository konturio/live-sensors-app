import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'user.dart';
import 'snapnshot_error.dart';

import 'measurement.dart';

class ParsingError extends Error {
  final String message;
  ParsingError(this.message);
}

class Snapshot {
  final String id;
  final User user;
  final DateTime startDateTime;
  final List<Measurement> measurements = <Measurement>[];
  SnapshotError? error;
  late DateTime? endDateTime;
  late Position? position;

  Snapshot({
    required this.user,
    required this.id,
    required this.startDateTime,
    this.endDateTime,
    this.error,
    this.position,
  });

  factory Snapshot.empty(User u) {
    return Snapshot(
      user: u,
      id: Uuid().v4(),
      startDateTime: DateTime.now(),
    );
  }

  seal(Position pos) {
    position = pos;
    endDateTime = DateTime.now();
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
    );

    if (json['measurements'] != null) {
      for (String m in json['measurements'] as List<String>) {
        throw Error(); // TODO: Not implemented yet
        // Measurement measurement = m;
        // snap.measurements.add(measurement);
      }
    }

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
        'measurements': measurements, // TODO - implement serialization
        'error': error?.toJson(),
      };
}
