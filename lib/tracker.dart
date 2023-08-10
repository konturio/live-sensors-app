import 'dart:async';
import 'package:live_sensors/logger/logger.dart';

import 'sensors/sensors.dart';
import 'snapshot/snapshot.dart';
import 'queue/queue.dart';
import 'user/user.dart';

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
      if (isPaused) return;
      snap.add(events);
    });

    // Finalize current snapshot, and create next one
    bool skip = false; // After pause we still ned finalize current chunk
    positionSubscription = position.listen((event) {
      if (isPaused && skip) {
        // Tracking paused and last snapshot finalized
        return;
      }
      snap.seal(event);
      queue.add(snap);
      snap = Snapshot.init(user, userAgent);
      skip = isPaused;
    });

    if (isPaused) {
      pause();
    }
  }

  pause() {
    isPaused = true;

    // sensorsSubscription?.pause();
    // positionSubscription?.pause();
  }

  resume() {
    isPaused = false;
    // sensorsSubscription?.resume();
    // positionSubscription?.resume();
  }

  dispose() async {
    await sensorsSubscription?.cancel();
    await positionSubscription?.cancel();
  }
}
