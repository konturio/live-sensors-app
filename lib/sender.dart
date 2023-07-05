import 'queue.dart';
import 'snapshot.dart';
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
          logger.info('Sending snapshot: ${nextSnap.toString()}');
          await api.sendSnapshot(nextSnap);
          logger.info('Snapshot sended: ${nextSnap.id}');
          queue.remove(nextSnap);
        } catch (error) {
          logger.error('Fail to send snapshot ${nextSnap.id}');
          // TODO: set error
          // nextSnap.error
          try {
            logger.info('Saving snapshot in persist storage: ${nextSnap.id}');
            await storage.save(nextSnap);
          } catch (e) {
            logger.error(
                'Saving snapshot in persist storage error: ${nextSnap.id}');
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
