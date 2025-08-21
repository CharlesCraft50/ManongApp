import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:manong_application/models/app_user.dart';

class AuthService {
  final storage = FlutterSecureStorage();
  final String? baseUrl = dotenv.env['APP_URL'];

  final Logger logger = Logger('auth_service');

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Accept': 'application/json'},
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'token', value: data['token']);
      return true;
    }

    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Accept': 'application/json'},
      body: {'name': name, 'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'token', value: data['token']);
      return true;
    }

    return false;
  }

  Future<String?> getToken() async {
    return storage.read(key: 'token');
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential credential) onAutoVerified,
    required Function(FirebaseAuthException error) onFailed,
    required Function(String verificationId) onCodeSent,
  }) async {
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        onAutoVerified(credential);
      },
      verificationFailed: (FirebaseAuthException error) {
        onFailed(error);
      },
      codeSent: (String verificationId, int? forceResendingToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
  }

  Future<String?> signInWithCredential(
    String? verificationId,
    String? smsCode,
  ) async {
    if (verificationId == null || smsCode == null) {
      throw Exception('Verification ID and SMS code must not be null');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final response = await auth.signInWithCredential(credential);
    return response.user?.phoneNumber;
  }

  Future<bool> isTokenSet() async {
    String? token = await storage.read(key: 'token');
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, dynamic>> registerOrLoginUser(String phoneNumber) async {
    final baseUrl = dotenv.env['APP_URL'];

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/register'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({'phone': phoneNumber}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        await storage.write(key: 'laravel_token', value: data['token']);
        return data;
      } else if (response.statusCode == 422) {
        final errors = json.decode(response.body);
        throw Exception(
          'Validation failed: ${errors['errors']['phone']?[0] ?? 'Invalid phone number'}',
        );
      } else {
        throw Exception('Registration failed ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> completePhoneAuth(
    String verificationId,
    String smsCode,
  ) async {
    try {
      final verifiedPhone = await signInWithCredential(verificationId, smsCode);
      final result = await registerOrLoginUser(verifiedPhone!);
      return result;
    } catch (e) {
      throw Exception('Phone authentication failed: $e');
    }
  }

  Future<String?> getLaravelToken() async {
    return await storage.read(key: 'laravel_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await getLaravelToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    Exception? lastException;

    try {
      final token = await getLaravelToken();

      if (token != null && baseUrl != null) {
        final response = await http
            .post(
              Uri.parse('$baseUrl/logout'),
              headers: {
                'Content-Type':
                    'application/json', // Fixed typo: was 'Application'
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 15));

        // Log the response for debugging
        if (response.statusCode != 200) {
          logger.warning(
            'Laravel logout warning: ${response.statusCode} - ${response.body}',
          );
        }
      }
    } catch (e) {
      logger.severe('Laravel logout failed: $e');
      lastException = Exception('Server logout failed: $e');
    }

    // Always clear local storage regardless of server response
    try {
      await storage.delete(key: 'laravel_token');
      await storage.delete(
        key: 'token',
      ); // Also clear the old token if it exists
    } catch (e) {
      logger.severe('Failed to clear local tokens: $e');
      lastException = Exception('Failed to clear local data: $e');
    }

    // Always sign out from Firebase
    try {
      await auth.signOut();
    } catch (e) {
      logger.severe('Firebase sign out failed: $e');
      lastException = Exception('Firebase sign out failed: $e');
    }

    // If there were any critical errors, throw the last one
    if (lastException != null) {
      throw lastException;
    }
  }

  Future<AppUser> getMyProfile() async {
    try {
      final token = await getLaravelToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/get'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return AppUser.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        // Token might be expired, clear it
        await storage.delete(key: 'laravel_token');
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception(
          'Failed to load profile: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error getting profile: $e');
    }
  }

  // Helper method to clear all stored data (useful for complete reset)
  Future<void> clearAllData() async {
    try {
      await storage.deleteAll();
      await auth.signOut();
    } catch (e) {
      logger.severe('Error clearing all data: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile(String name, String email) async {
    try {
      final token = await getLaravelToken();

      final response = await http
          .post(
            Uri.parse('$baseUrl/edit-profile'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'name': name, 'email': email}),
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final responseBody = jsonDecode(response.body);
        logger.warning(
          'Failed to update profile: ${response.statusCode} ${responseBody['errors']}',
        );
        return {};
      }
    } catch (e) {
      logger.severe('Error to update profile $e');
      return {};
    }
  }
}
