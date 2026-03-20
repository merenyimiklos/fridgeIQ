import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:fridgeiq/core/constants/app_constants.dart';

class FirebaseDatabaseService {
  static const String _baseUrl = AppConstants.firebaseDatabaseUrl;

  final http.Client _client;

  FirebaseDatabaseService({http.Client? client})
      : _client = client ?? http.Client();

  /// Gets all items from a collection. Returns a map of id -> item data.
  Future<Map<String, Map<String, dynamic>>> getAll(String collection) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/$collection.json'),
    );
    _checkResponse(response);
    final data = json.decode(response.body);
    if (data == null) return {};
    final map = Map<String, dynamic>.from(data as Map);
    return map.map(
      (key, value) => MapEntry(key, Map<String, dynamic>.from(value as Map)),
    );
  }

  /// Gets a single item by id from a collection.
  Future<Map<String, dynamic>?> getById(String collection, String id) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/$collection/$id.json'),
    );
    _checkResponse(response);
    final data = json.decode(response.body);
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  /// Saves (creates or updates) an item in a collection.
  Future<void> put(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/$collection/$id.json'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    _checkResponse(response);
  }

  /// Deletes an item from a collection.
  Future<void> delete(String collection, String id) async {
    final response = await _client.delete(
      Uri.parse('$_baseUrl/$collection/$id.json'),
    );
    _checkResponse(response);
  }

  /// Deletes multiple items from a collection using a single batch update.
  Future<void> deleteAll(String collection, List<String> ids) async {
    if (ids.isEmpty) return;
    final updates = <String, dynamic>{
      for (final id in ids) '$collection/$id': null,
    };
    final response = await _client.patch(
      Uri.parse('$_baseUrl/.json'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updates),
    );
    _checkResponse(response);
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Firebase request failed [${response.statusCode}]: ${response.body}',
      );
    }
  }
}
