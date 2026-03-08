import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Change this to your backend URL
  // For Android emulator: 10.0.2.2:3000
  // For iOS simulator / web: localhost:3000
  // For real device: your machine's IP
  static const String _baseUrl = 'http://10.0.2.2:3000/api';

  static String? _token;

  static void setToken(String? token) {
    _token = token;
  }

  static String? get token => _token;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ==================== AUTH ====================

  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      _token = data['token'];
    }
    return data;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      _token = data['token'];
    }
    return data;
  }

  static Future<Map<String, dynamic>> getMe() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/auth/me'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  // ==================== TOPICS ====================

  static Future<Map<String, dynamic>> getTopics({
    String? search,
    String? level,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (level != null) params['level'] = level;

    final uri = Uri.parse('$_baseUrl/topics').replace(queryParameters: params);
    final response = await http.get(uri, headers: _headers);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createTopic({
    required String title,
    required String prompt,
    required String level,
    String duration = '3-5 phút',
    List<String> questions = const [],
    List<String> tags = const [],
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/topics'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'prompt': prompt,
        'level': level,
        'duration': duration,
        'questions': questions,
        'tags': tags,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateTopic({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/topics/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteTopic(String id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/topics/$id'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> generateTopics({
    String level = 'intermediate',
    int count = 3,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/topics/generate'),
      headers: _headers,
      body: jsonEncode({'level': level, 'count': count}),
    );
    return jsonDecode(response.body);
  }

  // ==================== RECORDINGS ====================

  static Future<Map<String, dynamic>> uploadRecording({
    required String audioFilePath,
    required String topicId,
    required int duration,
  }) async {
    final uri = Uri.parse('$_baseUrl/recordings/upload');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $_token';
    request.fields['topicId'] = topicId;
    request.fields['duration'] = duration.toString();
    request.files.add(
      await http.MultipartFile.fromPath('audio', audioFilePath),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getRecordings({
    int page = 1,
    int limit = 20,
  }) async {
    final uri = Uri.parse('$_baseUrl/recordings').replace(
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
    final response = await http.get(uri, headers: _headers);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getRecording(String id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/recordings/$id'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  // ==================== ADMIN ====================

  static Future<Map<String, dynamic>> getAdminStats() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/admin/stats'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }
}
