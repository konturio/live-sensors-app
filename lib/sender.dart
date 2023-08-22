import 'package:live_sensors/logger/logger.dart';
import 'api/errors.dart';
import 'http_client/errors.dart';
import 'snapshot/snapnshot_error.dart';
import 'snapshot/snapshot.dart';
import 'snapshot/snapshot_to_geojson.dart';
import 'queue/queue.dart';
import 'storage/storage.dart';
import 'api/api_client.dart';

class Sender {
  final Logger logger = Logger();
  late SnapshotsQueue queue;
  late ApiClient api;
  late Storage storage;
  int counter = 0;
  bool isStopped = false;

  Sender();

  setup({
    required api,
    required queue,
    required storage,
  }) {
    this.api = api;
    this.queue = queue;
    this.storage = storage;
  }

  run() {
    isStopped = false;
    sendSnapshotsFromQueue();
    sendSnapshotsFromStorage();
  }

  stop() {
    isStopped = true;
  }

  sendSnapshotsFromQueue() async {
    logger.info('Start sending from snapshot queue');
    while (!isStopped) {
      try {
        Snapshot nextSnap = queue.next();
        try {
          final json = snapshotToGeoJson(nextSnap).toJson();
          await api.sendSnapshot(json);
          counter++;
          queue.remove(nextSnap);
        } on BadRequestException {
          // TODO: remove this after storage implemented
          logger.error(
              'Fail to send snapshot ${nextSnap.id}.\n Reason: Bad request');
          queue.remove(nextSnap);
        } on AuthException catch (e) {
          logger.error(
            'Fail to send snapshot ${nextSnap.id}.\n Reason: $e',
          );
        } on SnapshotError catch (e) {
          logger.error(
            'Fail to send snapshot ${nextSnap.id}.\n Reason: ${e.message}',
          );
          nextSnap.error = e;
        } catch (e) {
          logger.error(
            'Fail to send snapshot ${nextSnap.id}.\n Reason: $e',
          );
        }
      } on StateError {
        // No more snapshots in queue
        await Future.delayed(const Duration(seconds: 1));
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
