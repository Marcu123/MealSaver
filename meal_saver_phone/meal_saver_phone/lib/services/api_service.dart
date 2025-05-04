import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:meal_saver_phone/models/ai_recipe_dto.dart';
import 'package:meal_saver_phone/models/food_dto.dart';
import 'package:meal_saver_phone/models/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meal_saver_phone/models/recipe_dto.dart';

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
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final data = jsonDecode(response.body);
      return data['message'] ?? "Something went wrong.";
    } catch (e) {
      return "Connection error! Verify your internet.";
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

  Future<String> sendForgotPasswordEmail(String email) async {
    final url = Uri.parse("$baseUrl/auth/forgot-password");
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({"email": email});

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        return "Email sent successfully! Check your inbox.";
      } else {
        final data = jsonDecode(response.body);
        return data['message'] ?? "An error occurred!";
      }
    } catch (e) {
      return "Connection error! Verify your internet connection! ";
    }
  }

  Future<String> resetPassword(String token, String password) async {
    final url = Uri.parse("$baseUrl/auth/reset-password");
    final body = jsonEncode({"token": token, "password": password});

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        return "Password reset successfully!";
      } else {
        final data = jsonDecode(response.body);
        return data['message'] ?? "Reset failed.";
      }
    } catch (e) {
      return "Connection error! Verify your internet.";
    }
  }

  Future<String> changePassword(String oldPassword, String newPassword) async {
    final url = Uri.parse("$baseUrl/users/change-password");

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) return "User not logged in";

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return "Password changed successfully!";
      } else {
        return "Error: ${response.body}";
      }
    } catch (e) {
      return "Connection error!";
    }
  }

  Future<String> updateUserInfo({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    String? profileImageUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      return "Not authenticated";
    }

    final url = Uri.parse('$baseUrl/users/update-profile');

    final body = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'username': username,
    };

    if (profileImageUrl != null) {
      body['profileImageUrl'] = profileImageUrl;
    }

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return "Profile updated successfully!";
      } else {
        return "Update failed: ${response.body}";
      }
    } catch (e) {
      return "Connection error: $e";
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      print("⚠️ No token found");
      return null;
    }

    final url = Uri.parse('$baseUrl/users/me');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("📥 Status code: ${response.statusCode}");
      print("📥 Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print("❌ Error fetching user data: $e");
      return null;
    }
  }

  Future<String> addFood({
    required String name,
    required int size,
    required String expirationDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      return "User not logged in";
    }

    final userData = await getCurrentUser();
    final username = userData?['username'];

    if (username == null) {
      return "Username not found.";
    }

    final url = Uri.parse('$baseUrl/foods');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'size': size,
          'expirationDate': expirationDate,
          'username': username,
        }),
      );

      print("📤 Sent: $name, $size, $expirationDate, $username");
      print("📥 Status: ${response.statusCode}");
      print("📥 Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return "Food added successfully";
      } else {
        final data = jsonDecode(response.body);
        return data['message'] ?? "Error adding food";
      }
    } catch (e) {
      print("❌ Error sending food: $e");
      return "Connection error! Verify your internet.";
    }
  }

  Future<List<AppNotification>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) return [];

    final url = Uri.parse('$baseUrl/notifications/me');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => AppNotification.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<void> markNotificationAsRead(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse('$baseUrl/notifications/$id/read');

    await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<void> deleteNotification(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse('$baseUrl/notifications/$id');

    await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<void> clearAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse('$baseUrl/notifications/clear');

    await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<List<AiRecipeDTO>> getAiGeneratedRecipes({
    int page = 0,
    int size = 5,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final uri = Uri.parse(
      "http://10.0.2.2:8082/api/ai/recipes?page=$page&size=$size",
    );
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<AiRecipeDTO>.from(
        data.map((item) => AiRecipeDTO.fromJson(item)),
      );
    } else {
      throw Exception(
        'Failed to generate AI recipes: HTTP ${response.statusCode}',
      );
    }
  }

  Future<List<FoodDTO>> getMyFoods() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final url = Uri.parse("$baseUrl/foods/my");
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('📥 Response (foods/my): ${response.statusCode}');
    print('📥 Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<FoodDTO>.from(data.map((item) => FoodDTO.fromJson(item)));
    } else {
      throw Exception('Failed to fetch foods: HTTP ${response.statusCode}');
    }
  }

  Future<String> updateFood(String oldName, Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final url = Uri.parse('$baseUrl/foods/$oldName');

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return "Food updated successfully!";
      } else {
        return "Update failed: ${response.body}";
      }
    } catch (e) {
      return "Connection error!";
    }
  }

  Future<void> deleteFood(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final url = Uri.parse('$baseUrl/foods/$id');

    await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<List<FoodDTO>> getExpiringSoonFoods() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) throw Exception('User not authenticated');

    final url = Uri.parse("$baseUrl/foods/expiring-soon");
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<FoodDTO>.from(data.map((item) => FoodDTO.fromJson(item)));
    } else {
      throw Exception(
        'Failed to fetch expiring foods: HTTP ${response.statusCode}',
      );
    }
  }

  Future<List<FoodDTO>> getExpiredFoods() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) throw Exception('User not authenticated');

    final url = Uri.parse("$baseUrl/foods/expired");
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<FoodDTO>.from(data.map((item) => FoodDTO.fromJson(item)));
    } else {
      throw Exception(
        'Failed to fetch expired foods: HTTP ${response.statusCode}',
      );
    }
  }

  Future<String?> uploadToCloudinary(Uint8List imageData) async {
    const cloudName = 'dkx85t4ni';
    const uploadPreset = 'flutter_unsigned';

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request =
        http.MultipartRequest('POST', uri)
          ..fields['upload_preset'] = uploadPreset
          ..files.add(
            http.MultipartFile.fromBytes(
              'file',
              imageData,
              filename: 'image.jpg',
            ),
          );

    final response = await request.send();

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final data = json.decode(resStr);
      print("Image uploaded: ${data['secure_url']}");
      return data['secure_url'];
    } else {
      print("Upload failed: ${response.statusCode}");
      return null;
    }
  }

  Future<void> sendImageUrlToBackend(String username, String url) async {
    final backendUrl = 'http://10.0.2.2:8082/api/users/upload-profile-image';

    final response = await http.put(
      Uri.parse(backendUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'url': url}),
    );

    if (response.statusCode == 204) {
      print('✅ Link salvat în backend fără token');
    } else {
      print('❌ Eroare salvare: ${response.statusCode} -> ${response.body}');
    }
  }
}
