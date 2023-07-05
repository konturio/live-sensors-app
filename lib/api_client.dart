import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // Future<void> login() await {

  // }

  Future<void> sendSnapshot(Map<String, dynamic> payload) async {
    return Future.delayed(const Duration(seconds: 3));

    final response = await http.post(
      Uri.parse('https://disaster.ninja/active/api/features/live-sensor'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save snapshot.');
    }
  }
}
