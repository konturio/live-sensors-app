import 'package:live_sensors/logger/logger.dart';
import 'api/errors.dart';
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
    sendSnapshotsFromQueue();
    sendSnapshotsFromStorage();
  }

  sendSnapshotsFromQueue() async {
    logger.info('Start sending from snapshot queue');
    while (true) {
      try {
        Snapshot nextSnap = queue.next();
        try {
          final json = snapshotToGeoJson(nextSnap).toJson();
          await api.sendSnapshot(json);
          queue.remove(nextSnap);
        } on UnauthorizedException {
          
        } catch (error) {
          SnapshotError errMessage = error is SnapshotError ? error : SnapshotError.unknown('unknown');
          logger.error('Fail to send snapshot ${nextSnap.id}.\n Reason: ${errMessage.message} ');
          nextSnap.error = errMessage;
          try {
            // logger.info(
            //   'Saving snapshot in persist storage: ${nextSnap.id}',
            // );
            // await storage.save(nextSnap);
          } catch (e) {
            // logger.error(
            //   'Saving snapshot in persist storage error: ${nextSnap.id}',
            // );
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
