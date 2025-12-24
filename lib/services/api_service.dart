import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiService {
  // Update this with your Flask backend URL
  static const String baseUrl =
      'http://192.168.100.12:5000/api'; // Change to your backend URL (no leading space)

  // For Android emulator, use: http://10.0.2.2:5000/api
  // For iOS simulator, use: http://localhost:5000/api
  // For physical device, use your computer's IP: http://192.168.x.x:5000/api

  static Future<UserModel> registerUser({
    required String firebaseUid,
    required String username,
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'firebase_uid': firebaseUid,
          'username': username,
          'email': email,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data);
      } else {
        final bodyText = response.body.isNotEmpty ? response.body : '<empty>';
        String msg;
        try {
          final error = jsonDecode(bodyText);
          msg = error['message'] ?? bodyText;
        } catch (_) {
          msg = bodyText;
        }
        throw Exception(
            'Registration failed: HTTP ${response.statusCode} - $msg');
      }
    } on http.ClientException catch (e) {
      throw Exception(
          'Network error: Check your internet connection or server status. (${e.message})');
    } catch (e) {
      // Always throw a descriptive Exception so UI can display it
      if (e.toString().contains('is not a subtype of type')) {
        throw Exception('Server error: Invalid response format');
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<UserModel> loginUser({
    required String firebaseUid,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'firebase_uid': firebaseUid,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data);
      } else {
        final bodyText = response.body.isNotEmpty ? response.body : '<empty>';
        String msg;
        try {
          final error = jsonDecode(bodyText);
          msg = error['message'] ?? bodyText;
        } catch (_) {
          msg = bodyText;
        }
        throw Exception('Login failed: HTTP ${response.statusCode} - $msg');
      }
    } on http.ClientException catch (e) {
      throw Exception(
          'Network error: Check your internet connection or server status. (${e.message})');
    } catch (e) {
      if (e.toString().contains('is not a subtype of type')) {
        throw Exception('Server error: Invalid response format');
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }
}
