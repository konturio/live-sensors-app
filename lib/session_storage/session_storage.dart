import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:live_sensors/entities/session.dart';

class SessionStorage {
  static const storage = FlutterSecureStorage();
  static const String key = 'session';

  Future<Session> restoreLast() async {
    final json = await storage.read(
      key: SessionStorage.key,
    );
    if (json != null) {
      return Session.fromJson(jsonDecode(json));
    } else {
      return Session();
    }
  }

  void saveSession(Session session) async {
    WidgetsFlutterBinding.ensureInitialized();
    await storage.write(
      key: SessionStorage.key,
      value: jsonEncode(session.toJson()),
    );
  }
}
