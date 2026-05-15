import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/assignment.dart';

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const int _timeoutSeconds = 15;

  Future<List<Assignment>> fetchAssignments() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/posts?_limit=20'))
          .timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Assignment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load assignments. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Assignment> fetchAssignment(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/posts/$id'))
          .timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        return Assignment.fromJson(json.decode(response.body));
      } else {
        throw Exception('Assignment not found. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Assignment> createAssignment(Assignment assignment) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/posts'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: json.encode(assignment.toJson()),
          )
          .timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 201) {
        return Assignment.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create assignment. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Assignment> updateAssignment(Assignment assignment) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/posts/${assignment.id}'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: json.encode(assignment.toJson()),
          )
          .timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        return Assignment.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update assignment. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteAssignment(int id) async {
    try {
      final response = await http
          .delete(Uri.parse('$_baseUrl/posts/$id'))
          .timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete assignment. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}