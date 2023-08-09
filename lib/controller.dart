import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:live_sensors/logger/logger.dart';
import 'package:live_sensors/utils.dart';

import 'auth/auth_service.dart';
import 'sensors/sensors.dart';
import 'user/user.dart';
import 'api/api_client.dart';
import 'geo_locator/position.dart';
import 'queue/queue.dart';
import 'storage/storage.dart';

import 'config.dart';
import 'sender.dart';
import 'tracker.dart';

class AppControllerState {
  bool isTracking = false;
  bool isAuthorized = false;
  bool isBooted = false;
}

class AppController extends SimpleState<AppControllerState> {
  final Logger logger = Logger();
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
    sensors = Sensors();
    geoLocator = GeoLocator();
  }

  @override
  initState() {
    return AppControllerState();
  }

  init() async {
    AppConfig config = AppConfig().read();
    User? user = await auth.restoreSession();
    setState(() {
      state.isAuthorized = auth.isAuthorized;
      state.isBooted = true;
    });

    if (auth.isAuthorized && user != null) {
      await setup(user);
      start();
    }
  }

  login(String login, String password) async {
    User? user = await auth.login(email: login, password: password);
    setState(() {
      state.isAuthorized = auth.isAuthorized;
    });
    if (auth.isAuthorized && user != null) {
      try {
        await setup(user);
        start();
      } catch (e) {
        logger.error('Failed to start. Reason: ${e.toString()}');
      }
    }
  }

  setup(User user) async {
    api = ApiClient();
    queue = SnapshotsQueue();
    tracker = Tracker();
    storage = Storage();
    sender = Sender();

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

  logout() async {
    pauseTracking();
    tracker.dispose();
    await auth.logout();
    setState(() {
      state.isAuthorized = auth.isAuthorized;
    });
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
