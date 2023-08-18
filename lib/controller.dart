import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:live_sensors/logger/logger.dart';
import 'package:live_sensors/utils/state.dart';

import 'auth/auth_service.dart';
import 'http_client/open_id_api.dart';
import 'http_client/open_id_client.dart';
import 'http_client/tokens.dart';
import 'sensors/sensors.dart';
import 'user/user.dart';
import 'api/api_client.dart';
import 'geo_locator/position.dart';
import 'queue/queue.dart';
import 'storage/storage.dart';

import 'config.dart';
import 'sender.dart';
import 'tracker.dart';

// TODO Inject auti in api? or api in auth? How to refresh token
class AppControllerState {
  // Enabled tracking or not
  bool isTracking = false;
  // Application ready for work or not
  bool isBooted = false;
  // User authorized or not
  bool isAuthorized = false;
}

class AppController extends SimpleState<AppControllerState> {
  final Logger logger = Logger();
  final GeoLocator geoLocator;
  final Sensors sensors;

  late AppConfig config;
  late SnapshotsQueue queue;
  late ApiClient api;
  late OpenIdClient openIdClient;

  /* Listen sensors and position, and creates new snapshots in queue */
  late Tracker tracker;
  /* Store snapshots on hard drive */
  late Storage storage;
  /* Sends snapshots from queue */
  late Sender sender;

  AppController():
    sensors = Sensors(),
    geoLocator = GeoLocator();

  @override
  initState() {
    return AppControllerState();
  }

  // Create common application structure
  init() async {
    SessionStorage sessionStorage = SessionStorage();
    config = AppConfig().read();
    Session session = await sessionStorage.restoreLast();

    openIdClient = OpenIdClient(
      OpenIdApi(
          refreshPath: Uri.parse(
        'https://keycloak01.kontur.io/auth/realms/kontur/protocol/openid-connect/token',
      )),
      tokens: session.tokens,
      postAuth: (tokens) {
        if (tokens) {
          _postLogin(tokens);
        } else {
          _postLogout();
        }
      },
      postRefresh: (tokens) {
        session.tokens = tokens;
        sessionStorage.saveSession(session);
      },
    );

    api = ApiClient(openIdClient);
  }

  login(String login, String password) async {
    await openIdClient.login(email: login, password: password);
  }

  _postLogin(Tokens tokens) async {
    User user = User(id: tokens.sessionId);
    try {
      setState(() {
        state.isAuthorized = true;
      });
      await setup(user);
      start();
    } catch (e) {
      logger.error('Failed to start. Reason: ${e.toString()}');
    }
  }

  setup(User user) async {
    queue = SnapshotsQueue();
    tracker = Tracker();
    storage = Storage();
    sender = Sender();

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
    await _postLogout();
  }

  _postLogout() async {
    stop();
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

  stop() {
    tracker.dispose();
    tracker.pause();
    setState(() {
      state.isTracking = false;
    });
  }

  pause() {
    tracker.pause();
    setState(() {
      state.isTracking = false;
    });
  }

  resume() {
    tracker.resume();
    setState(() {
      state.isTracking = true;
    });
  }
}
