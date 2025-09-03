import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;
import 'package:manong_application/api/auth_service.dart';

class UserPaymentMethodApiService {
  final Logger logger = Logger('UserPaymentMethodApiService');
  final String? baseUrl = dotenv.env['APP_URL_API'];

  Future<Map<String, dynamic>?> saveUserPaymentMethod(
    int paymentMethodId,
  ) async {
    try {
      if (baseUrl == null) {
        throw Exception('Base URL is not configured.');
      }

      final token = AuthService().getNodeToken();

      final response = await http.post(
        Uri.parse('$baseUrl/user-payment-methods'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseBody = response.body;
      final jsonData = jsonDecode(responseBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonData;
      } else {
        logger.warning(
          'Failed to save card ${response.statusCode} $responseBody',
        );

        return null;
      }
    } catch (e) {
      logger.severe('Error saving payment method $e');
    }

    return null;
  }
}
