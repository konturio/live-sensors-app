import 'package:flutter/material.dart';
import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:live_sensors/auth_service.dart';
import 'package:live_sensors/logger.dart';
import 'package:live_sensors/utils.dart';
import 'package:live_sensors/views/logger.dart';
import 'package:live_sensors/views/query.dart';

import 'config.dart';
import 'sender.dart';
import 'sensors.dart';
import 'tracker.dart';
import 'user.dart';
import 'api_client.dart';
import 'position.dart';
import 'storage.dart';
import 'queue.dart';
import 'views/toggle_tracking_btn.dart';


class AppControllerState {
  bool isTracking = false;
}

class AppController extends SimpleState<AppControllerState> {
  late SnapshotsQueue queue;
  late AuthService auth;
  late ApiClient api;
  late Tracker tracker;
  late Storage storage;
  late Sender sender;
  late Sensors sensors;
  late GeoLocator geoLocator;

  AppController() {
    auth = AuthService();
    api = ApiClient();
    queue = SnapshotsQueue();
    tracker = Tracker();
    storage = Storage();
    sender = Sender();
    sensors = Sensors();
    geoLocator = GeoLocator();
  }
  
  @override
  initState() {
    return AppControllerState();
  }

  init() async {
    AppConfig config = AppConfig().read();

    User user = await auth.login(
      email: config.email,
      password: config.password,
    );

    api.authorize(user);

    sender.setup(
      api: api,
      storage: storage,
      queue: queue,
    );

    await FkUserAgent.init();
    String userAgent = FkUserAgent.userAgent ?? 'Unknown';

    tracker.setup(
      user: user,
      userAgent: userAgent,
      queue: queue,
      sensors: sensors.stream,
      position: geoLocator.stream,
    );
  }

  start() {
    tracker.track();
    sender.run();
    setState(() {
      state.isTracking = true;
    });
  }

  pauseTracking() {
    tracker.pause();
    setState(() {
      state.isTracking = false;
    });
  }

  resumeTracking() {
    tracker.resume();
    setState(() {
      state.isTracking = true;
    });
  }
}

void main() async {
  final appController = AppController();
  runApp(LiveSensorsApp(controller: appController));
  await appController.init();
  Future(() {
    appController.start();
  });
}

class LiveSensorsApp extends StatelessWidget {
  final AppController controller;
  const LiveSensorsApp({super.key, required this.controller});

  toggleTrackerState() {}

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
              LoggerView(logger: Logger()),
              QueueView(queue: controller.queue),
            ],
          ),
          floatingActionButton: ToggleTrackingBtn(controller: controller),
        ),
      ),
    );
  }
}
