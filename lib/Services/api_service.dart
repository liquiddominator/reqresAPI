import 'dart:convert';
import 'package:reqres_api_andres/Models/Users.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://reqres.in/api';

  Future<Map<String, dynamic>> getUsers({int page = 1, int perPage = 6}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users?page=$page&per_page=$perPage')
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> users = data['data'];
      return {
        'users': users.map((json) => User.fromJson(json)).toList(),
        'total_pages': data['total_pages'],
        'current_page': data['page'],
        'per_page': data['per_page'],
        'total': data['total']
      };
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<bool> createUser(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toJson()),
    );
    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to create user');
    }
  }

  Future<bool> updateUser(int id, User user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update user');
    }
  }

  Future<void> deleteUser(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/users/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }
}