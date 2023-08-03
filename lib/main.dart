import 'package:flutter/material.dart';
import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:live_sensors/auth_service.dart';
import 'package:live_sensors/views/logger.dart';
import 'package:live_sensors/views/query.dart';

import 'sender.dart';
import 'sensors.dart';
import 'tracker.dart';
import 'user.dart';
import 'api_client.dart';
import 'position.dart';
import 'storage.dart';
import 'queue.dart';
import 'logger.dart';

final Logger logger = Logger();
final SnapshotsQueue queue = SnapshotsQueue();

void main() async {
  final auth = AuthService();
  const email = String.fromEnvironment('email');
  const password = String.fromEnvironment('password');
  runApp(const LiveSensorsApp());
  await FkUserAgent.init();

  if (email.isEmpty || password.isEmpty) {
    throw Exception("Setup .env first");
  }
  User user = await auth.login(
    email: email,
    password: password,
  );
  final ApiClient api = ApiClient(user);

  final Sender sender = Sender(
    logger: logger,
    api: api,
    storage: Storage(),
    queue: queue,
  );
  final Tracker tracker = Tracker(
    user: user,
    userAgent: FkUserAgent.userAgent!,
    queue: queue,
    logger: logger,
    sensors: Sensors().stream,
    position: GeoLocator(logger: logger).stream,
  );


  Future(() {
    tracker.track();
    sender.run();
  });
}

class LiveSensorsApp extends StatelessWidget {
  const LiveSensorsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live sensors',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        useMaterial3: true,
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Live sensors'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.info)),
                Tab(icon: Icon(Icons.dns)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              LoggerView(logger: logger),
              QueueView(queue: queue),
            ],
          ),
        ),
      ),
    );
  }
}
