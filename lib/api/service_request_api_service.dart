import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:manong_application/api/auth_service.dart';
import 'package:manong_application/models/service_request.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ServiceRequestApiService {
  final String? baseUrl = dotenv.env['APP_URL_API'];

  final Logger logger = Logger('ServiceRequestApiService');

  Future<Map<String, dynamic>?> uploadServiceRequest(
    ServiceRequest details,
  ) async {
    try {
      if (baseUrl == null) {
        throw Exception('Base URL is not configured.');
      }

      final token = await AuthService().getNodeToken();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/service-requests'),
      );

      request.fields['serviceItemId'] = details.serviceItemId.toString();
      request.fields['subServiceItemId'] = details.subServiceItemId.toString();
      if (details.otherServiceName != null) {
        request.fields['otherServiceName'] = details.otherServiceName!;
      }
      request.fields['serviceDetails'] = details.serviceDetails ?? '';
      request.fields['urgencyLevelId'] = (details.urgencyLevelIndex + 1)
          .toString();

      for (var i = 0; i < details.images.length; i++) {
        var imageFile = details.images[i];
        var stream = http.ByteStream(imageFile.openRead().cast());
        var length = await imageFile.length();

        var multipartFile = http.MultipartFile(
          'images',
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(responseBody);

        if (jsonData['warning'] != null) {
          logger.warning('Warning from server: ${jsonData['warning']}');
        }

        return jsonData;
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

  Future<Map<String, dynamic>?> fetchServiceRequests({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      if (baseUrl == null) {
        throw Exception('Base URL is not configured.');
      }

      final token = await AuthService().getNodeToken();

      final uri = Uri.parse('$baseUrl/service-requests').replace(
        queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      );

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 30));

      final responseBody = response.body;
      final jsonData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return jsonData['data'];
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

  Future<ServiceRequest?> fetchUserServiceRequest(int id) async {
    try {
      if (baseUrl == null) {
        throw Exception('Base URL is not configured.');
      }

      final token = await AuthService().getNodeToken();

      final response = await http.get(
        Uri.parse('$baseUrl/service-requests/$id'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseBody = response.body;

      final jsonData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return ServiceRequest.fromJson(jsonData['data']);
      } else {
        throw Exception(
          'Failed to load user service request: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      logger.severe('Error fetching user service request $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> chooseManong(int id, int manongId) async {
    try {
      final token = await AuthService().getNodeToken();
      final response = await http.post(
        Uri.parse('$baseUrl/service-requests/$id/choose-manong'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'manongId': manongId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        logger.warning('Can\'t choose manong. Please Try again later.');
      }
    } catch (e) {
      logger.severe('Error updating service request $e');
    }

    return null;
  }
}
