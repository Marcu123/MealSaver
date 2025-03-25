import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8082/api";

  Future<String> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/auth/register");

    final headers = {'Accept': '*/*', 'Content-Type': 'application/json'};

    final body = jsonEncode({
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "username": username,
      "password": password,
      "createdAt": DateTime.now().toIso8601String(),
      "updatedAt": DateTime.now().toIso8601String(),
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return "Registration successful!";
      } else {
        try {
          final responseData = jsonDecode(response.body);
          return responseData['message'] ?? "An error occurred!";
        } catch (_) {
          return response.body;
        }
      }
    } catch (e) {
      return "Connection error! Verify your internet connection!";
    }
  }

  Future<String> loginUser({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/auth/login");

    final headers = {'Accept': '*/*', 'Content-Type': 'application/json'};

    final body = jsonEncode({"username": username, "password": password});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final String token = responseData['token'];

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        print(prefs.getString('auth_token'));

        return "Login successful!";
      } else {
        try {
          final responseData = jsonDecode(response.body);
          return responseData['message'] ?? "An error occurred!";
        } catch (_) {
          return response.body;
        }
      }
    } catch (e) {
      return "Connection error! Verify your internet connection! ";
    }
  }
}
