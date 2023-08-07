import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:live_sensors/user/user.dart';
import 'package:live_sensors/logger/logger.dart';
import 'package:live_sensors/utils.dart';

class ApiClient {
  final Logger logger = Logger();
  User? user;

  ApiClient();

  authorize(User user) {
    this.user = user;
  }

  Future<void> sendSnapshot(Map<String, dynamic> payload) async {
    String? accessToken = user?.accessToken;
    if (accessToken == null) {
      throw ErrorWithMessage('Unauthorized request');
    }

    final response = await http.post(
      Uri.parse('https://disaster.ninja/active/api/features/live-sensor'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${accessToken}'
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save snapshot.');
    }
  }
}
