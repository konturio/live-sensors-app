import 'package:live_sensors/snapnshot_error.dart';
import 'queue.dart';
import 'snapshot.dart';
import 'snapshot_to_geojson.dart';
import 'storage.dart';
import 'api_client.dart';
import 'logger.dart';

class Sender {
  final SnapshotsQueue queue;
  final ApiClient api;
  final Storage storage;
  final Logger logger;

  Sender({
    required this.api,
    required this.queue,
    required this.storage,
    required this.logger,
  });

  run() {
    sendSnapshotsFromQueue();
    sendSnapshotsFromStorage();
  }

  sendSnapshotsFromQueue() async {
    while (true) {
      try {
        Snapshot nextSnap = queue.next();
        try {
          final json = snapshotToGeoJson(nextSnap).toJson();
          logger.info('Sending snapshot: $json');
          await api.sendSnapshot(json);
          logger.info('Snapshot sended: ${nextSnap.id}');
          queue.remove(nextSnap);
        } catch (error) {
          logger.error('Fail to send snapshot ${nextSnap.id}');
          nextSnap.error =
              error is SnapshotError ? error : SnapshotError.unknown('unknown');
          try {
            logger.info(
              'Saving snapshot in persist storage: ${nextSnap.id}',
            );
            // await storage.save(nextSnap);
          } catch (e) {
            logger.error(
              'Saving snapshot in persist storage error: ${nextSnap.id}',
            );
          }
        }
      } on StateError {
        await Future.delayed(const Duration(seconds: 10));
      }
    }
  }

  sendSnapshotsFromStorage() async {
    // while (true) {
    //   try {
    //     Snapshot nextSnap = await storage.next();
    //     try {
    //       await api.sendSnapshot(nextSnap);
    //       await storage.delete(nextSnap);
    //     } catch (error) {
    //       logger.error(error.toString());
    //     }
    //   } catch (e) {
    //     // TODO Catch .next error [StateError]
    //     logger.warn('Empty queue');
    //   }
    // }
  }
}
