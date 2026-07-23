import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

class AuthService {
  Future<void> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 201) {
      throw Exception(data["message"] ?? "Registration failed.");
    }
  }

  Future<Map<String, dynamic>> login(
      String email,
      String password,
      ) async {

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/login"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString("token", data["token"]);
      await prefs.setString("name", data["user"]["name"]);
      await prefs.setString("email", data["user"]["email"]);
      await prefs.setString("role", data["user"]["role"]);

      return data;
    } else {
      throw Exception(data["message"]);
    }
  }
}
