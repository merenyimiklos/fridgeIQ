import 'dart:convert';

import 'package:http/http.dart' as http;

/// Service for Firebase Auth REST API operations.
class FirebaseAuthService {
  final String _apiKey;
  final http.Client _client;

  static const String _baseUrl =
      'https://identitytoolkit.googleapis.com/v1/accounts';

  FirebaseAuthService({required String apiKey, http.Client? client})
      : _apiKey = apiKey,
        _client = client ?? http.Client();

  /// Creates a new user with email and password.
  /// Returns a map with `localId`, `email`, `idToken`, `refreshToken`.
  Future<Map<String, dynamic>> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl:signUp?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );
    return _handleResponse(response);
  }

  /// Signs in with email and password.
  /// Returns a map with `localId`, `email`, `idToken`, `refreshToken`.
  Future<Map<String, dynamic>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl:signInWithPassword?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );
    return _handleResponse(response);
  }

  /// Sends a password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl:sendOobCode?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'requestType': 'PASSWORD_RESET',
        'email': email,
      }),
    );
    _handleResponse(response);
  }

  /// Sends an email verification to the user.
  Future<void> sendEmailVerification(String idToken) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl:sendOobCode?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'requestType': 'VERIFY_EMAIL',
        'idToken': idToken,
      }),
    );
    _handleResponse(response);
  }

  /// Gets user data including emailVerified status.
  /// Returns a map with user info including `emailVerified`.
  Future<Map<String, dynamic>> getUserData(String idToken) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl:lookup?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'idToken': idToken}),
    );
    final data = _handleResponse(response);
    final users = data['users'] as List<dynamic>?;
    if (users == null || users.isEmpty) {
      throw Exception('User not found');
    }
    return Map<String, dynamic>.from(users.first as Map);
  }

  /// Signs in with a Google ID token using the verifyAssertion endpoint.
  Future<Map<String, dynamic>> signInWithGoogle({
    required String idToken,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl:signInWithIdp?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'postBody': 'id_token=$idToken&providerId=google.com',
        'requestUri': 'http://localhost',
        'returnSecureToken': true,
        'returnIdpCredential': true,
      }),
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = json.decode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = data['error'] as Map<String, dynamic>?;
      final message = error?['message'] as String? ?? 'Unknown error';
      throw FirebaseAuthException(message);
    }
    return data;
  }
}

class FirebaseAuthException implements Exception {
  final String code;

  FirebaseAuthException(this.code);

  String get userFriendlyMessage {
    switch (code) {
      case 'EMAIL_NOT_FOUND':
        return 'No account found with this email address.';
      case 'INVALID_PASSWORD':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Invalid email or password.';
      case 'USER_DISABLED':
        return 'This account has been disabled.';
      case 'EMAIL_EXISTS':
        return 'An account already exists with this email address.';
      case 'WEAK_PASSWORD : Password should be at least 6 characters':
        return 'Password should be at least 6 characters.';
      case 'TOO_MANY_ATTEMPTS_TRY_LATER':
        return 'Too many attempts. Please try again later.';
      case 'INVALID_EMAIL':
        return 'Please enter a valid email address.';
      default:
        if (code.startsWith('WEAK_PASSWORD')) {
          return 'Password should be at least 6 characters.';
        }
        return 'Authentication error: $code';
    }
  }

  @override
  String toString() => userFriendlyMessage;
}
