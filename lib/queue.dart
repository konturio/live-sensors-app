import 'package:live_sensors/snapshot.dart';

class SnapshotsQueue {
  final Set<Snapshot> _queue = <Snapshot>{};
  final List<Function> _listeners = <Function>[];

  add(Snapshot snapshot) {
    _queue.add(snapshot);
    _update();
  }

  remove(Snapshot snapshot) {
    _queue.remove(snapshot);
    _update();
  }

  Snapshot next() {
    return _queue.first;
  }

  _update() {
    for (final listener in _listeners) {
      listener(_queue);
    }
  }

  Function subscribe(void Function(Set<Snapshot>) listener) {
    _listeners.add(listener);
    Future(() => listener(_queue));
    return () {
      _listeners.remove(listener);
    };
  }
}
