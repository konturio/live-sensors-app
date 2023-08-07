import 'dart:async';
import 'package:live_sensors/logger.dart';

import 'sensors.dart';
import 'snapshot.dart';
import 'queue.dart';
import 'user.dart';

class Tracker {
  final Logger logger = Logger();
  late SnapshotsQueue queue;
  late User user;
  late String userAgent;
  late Stream<SensorsData> sensors;
  late Stream position;
  bool isPaused = false;
  StreamSubscription? sensorsSubscription;
  StreamSubscription? positionSubscription;

  Tracker();

  setup({
    required user,
    required userAgent,
    required queue,
    required sensors,
    required position,
  }) {
    this.user = user;
    this.userAgent = userAgent;
    this.queue = queue;
    this.sensors = sensors;
    this.position = position;
  }

  track() {
    Snapshot snap = Snapshot.init(user, userAgent);

    // Fill current snapshot with sensors data
    sensorsSubscription = sensors.listen((events) {
      snap.add(events);
    });

    // Finalize current snapshot, and create next one
    positionSubscription = position.listen((event) {
      snap.seal(event);
      queue.add(snap);
      snap = Snapshot.init(user, userAgent);
    });

    if (isPaused) {
      pause();
    }
  }

  pause() {
    isPaused = true;
    sensorsSubscription?.pause();
    positionSubscription?.pause();
  }

  resume() {
    isPaused = false;
    sensorsSubscription?.resume();
    positionSubscription?.resume();
  }
}
