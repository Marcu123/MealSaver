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
      return "Connection error! Verify your internet connection!";
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

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return "Food added successfully";
      } else {
        final data = jsonDecode(response.body);
        return data['message'] ?? "Error adding food";
      }
    } catch (e) {
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

    final decodedBody = utf8.decode(response.bodyBytes);

    if (response.statusCode == 200) {
      final data = jsonDecode(decodedBody);
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
      return data['secure_url'];
    } else {
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
  }

  Future<List<Map<String, dynamic>>> getRandomRecipeVideos({
    int count = 10,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) throw Exception("Not authenticated");

    final uri = Uri.parse(
      "http://10.0.2.2:8082/api/chef-battle/random?count=$count",
    );
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception("Failed to fetch recipe videos: ${response.statusCode}");
    }
  }

  Future<List<Map<String, dynamic>>> getMyRecipeVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse('http://10.0.2.2:8082/api/chef-battle/my-videos');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load your videos");
    }
  }

  Future<String> uploadRecipeVideo({
    required String videoUrl,
    required List<String> tags,
    required String description,
    String? thumbnailUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) return "Not authenticated";

    final url = Uri.parse("http://10.0.2.2:8082/api/chef-battle/upload");

    final body = {
      "videoUrl": videoUrl,
      "tags": tags,
      "description": description,
      "thumbnailUrl": thumbnailUrl ?? "",
      "createdAt": DateTime.now().toIso8601String(),
      "likes": 0,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return "Video uploaded successfully!";
      } else {
        return "Upload failed: ${response.statusCode}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<Map<String, dynamic>> likeRecipeVideo(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse('http://10.0.2.2:8082/api/chef-battle/$id/like');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to like video");
    }
  }

  Future<String?> uploadVideoToCloudinary(Uint8List videoBytes) async {
    const cloudName = 'dkx85t4ni';
    const uploadPreset = 'flutter_unsigned';

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/video/upload',
    );

    final request =
        http.MultipartRequest('POST', uri)
          ..fields['upload_preset'] = uploadPreset
          ..files.add(
            http.MultipartFile.fromBytes(
              'file',
              videoBytes,
              filename: 'video.mp4',
            ),
          );

    final response = await request.send();

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final data = jsonDecode(resStr);
      return data['secure_url'];
    } else {
      return null;
    }
  }

  Future<String> updateRecipeVideo({
    required int id,
    required String description,
    required List<String> tags,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse('http://10.0.2.2:8082/api/chef-battle/$id');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'id': id, 'description': description, 'tags': tags}),
    );

    if (response.statusCode == 200) {
      return "Video updated successfully!";
    } else {
      return "Failed to update video: ${response.statusCode}";
    }
  }

  Future<String> deleteRecipeVideo(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse('http://10.0.2.2:8082/api/chef-battle/$id');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 204) {
      return "Video deleted successfully!";
    } else {
      return "Failed to delete video: ${response.statusCode}";
    }
  }

  Future<void> unlikeRecipeVideo(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse('http://10.0.2.2:8082/api/chef-battle/$id/unlike');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to unlike video: ${response.statusCode}");
    }
  }

  Future<List<Map<String, dynamic>>> getLikedVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse('http://10.0.2.2:8082/api/chef-battle/liked');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load liked videos');
    }
  }

  Future<List<Map<String, dynamic>>> getVideosByUsername(
    String username,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) throw Exception("Not authenticated");

    final uri = Uri.parse("$baseUrl/chef-battle/by-user/$username");
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception("Failed to fetch videos for $username");
    }
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final url = Uri.parse("$baseUrl/users/search?usernamePart=$query");
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception("User search failed");
    }
  }

  Future<List<Map<String, dynamic>>> filterVideosByTags(
    List<String> tags,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final uri = Uri.parse("$baseUrl/chef-battle/tags?tags=${tags.join(',')}");
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception("Video tag search failed: ${response.statusCode}");
    }
  }
}
