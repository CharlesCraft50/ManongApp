import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final storage = FlutterSecureStorage();
  final String? baseUrl = dotenv.env['APP_URL'];

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<bool> login(String email, String password) async {
    final response =  await http.post(
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
      body: {
        'name': name,
        'email': email,
        'password': password,
      }
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

  Future<void> logout() async {
    return storage.delete(key: 'token');
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential credential) onAutoVerified,
    required Function(FirebaseAuthException error) onFailed,
    required Function(String verificationId) onCodeSent,
  }) async {
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted:(PhoneAuthCredential credential) {
        onAutoVerified(credential);
      }, 
      
      verificationFailed:(FirebaseAuthException error) {
        onFailed(error);
      }, 
      
      codeSent:(String verificationId, int? forceResendingToken) {
        onCodeSent(verificationId);
      }, 
      
      codeAutoRetrievalTimeout:(verificationId) {
      },
    );
  }

  Future<void> signInWithCredential(String? verificationId, String? smsCode) async {
    if (verificationId == null || smsCode == null) {
      throw Exception('Verification ID and SMS code must not be null');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId, 
      smsCode: smsCode,
    );

    final response = await auth.signInWithCredential(credential);

    final tokenId = await response.user?.getIdToken();
    if (tokenId != null) {
      await storage.write(key: 'token', value: tokenId);

    }
  }

  Future<bool> isTokenSet() async {
    String? token = await storage.read(key: 'token');
    return token != null && token.isNotEmpty;
  }
}