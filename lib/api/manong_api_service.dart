import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:manong_application/api/auth_service.dart';
import 'package:manong_application/models/service_request.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ManongApiService {
  final String? baseUrl = dotenv.env['APP_URL'];

  final Logger logger = Logger('ManongApiService');

  Future<Map<String, dynamic>?> uploadServiceRequest(
    ServiceRequest details,
  ) async {
    try {
      if (baseUrl == null) {
        throw Exception('Base URL is not configured.');
      }

      final token = await AuthService().getLaravelToken();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/service-requests'),
      );

      request.fields['service_item_id'] = details.serviceItemId.toString();
      request.fields['sub_service_item_id'] = details.subServiceItemId
          .toString();
      if (details.otherServiceName != null) {
        request.fields['other_service_name'] = details.otherServiceName!;
      }
      request.fields['service_details'] = details.serviceDetails ?? '';
      request.fields['urgency_level_id'] = (details.urgencyLevelIndex + 1)
          .toString();

      for (var i = 0; i < details.images.length; i++) {
        var imageFile = details.images[i];
        var stream = http.ByteStream(imageFile.openRead().cast());
        var length = await imageFile.length();

        var multipartFile = http.MultipartFile(
          'images[]',
          stream,
          length,
          filename: imageFile.path.split('/').last,
        );

        request.files.add(multipartFile);
      }

      request.fields['latitude'] = details.latitude.toString();
      request.fields['longitude'] = details.longitude.toString();

      // Headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      logger.info(request.fields);
      logger.info(request.fields.entries);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody);
      } else {
        logger.warning('Upload failed with status: ${response.statusCode}');
        logger.warning('Response: $responseBody');
        throw Exception(
          'Upload failed with status ${response.statusCode}: $responseBody',
        );
      }
    } catch (e) {
      logger.severe('Error upload problem $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchServiceRequests() async {
    try {
      if (baseUrl == null) {
        throw Exception('Base URL is not configured.');
      }

      final token = await AuthService().getLaravelToken();

      final response = await http
          .get(
            Uri.parse('$baseUrl/service-requests'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to load service requests: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      logger.severe('Error fetching service requests $e');
    }
    return null;
  }
}
