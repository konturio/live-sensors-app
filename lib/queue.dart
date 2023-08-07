import 'package:live_sensors/snapshot.dart';
import 'package:live_sensors/logger.dart';
import 'package:live_sensors/utils.dart';

class SnapshotsQueue extends SimpleState<Set<Snapshot>> {
  final Logger logger = Logger();

  @override
  initState() {
    return <Snapshot>{};
  }

  add(Snapshot snapshot) {
    setState(() {
      state.add(snapshot);
    });
  }

  remove(Snapshot snapshot) {
    setState(() {
      state.remove(snapshot);
    });
  }

  Snapshot next() {
    return state.first;
  }
}
