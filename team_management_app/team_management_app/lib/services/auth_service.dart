import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'https://team-management-api.dops.tech/api';

  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      body: jsonEncode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Decode the response and extract the token
      final data = jsonDecode(response.body);
      final token = data['data']['token'];

      // Print the token in the console
      print('Access Token: $token');

      // Save token to be used elsewhere (e.g., for authenticated requests)
      return true;
    } else {
      return false;
    }
  }
}
