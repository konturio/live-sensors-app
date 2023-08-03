import 'sensors.dart';
import 'snapshot.dart';
import 'logger.dart';
import 'queue.dart';
import 'user.dart';

class Tracker {
  final SnapshotsQueue queue;
  final Logger logger;
  final User user;
  final String userAgent;
  final Stream<SensorsData> sensors;
  final Stream position;

  Tracker({
    required this.user,
    required this.userAgent,
    required this.queue,
    required this.logger,
    required this.sensors,
    required this.position,
  });

  Future<void> track() async {
    Snapshot snap = Snapshot.init(user, userAgent);

    sensors.listen((events) {
      snap.add(events);
    });

    position.listen((event) {
      snap.seal(event);
      queue.add(snap);
      snap = Snapshot.init(user, userAgent);
    });
  }
}
