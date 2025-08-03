import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../models/service_item.dart';

Future <List<ServiceItem>> fetchServiceItems() async {
  final box = GetStorage();
  const cacheKey = 'cached_service_items';

  try {
    final baseUrl = Uri.parse('${dotenv.env['APP_URL']}/service-items');
    final response = await http.get(baseUrl); 

    if (response.statusCode == 200) {

      List<dynamic> jsonData = json.decode(response.body);

      await box.write(cacheKey, response.body);

      return jsonData.map((item) => ServiceItem.fromJson(item)).toList();

    } else {
      throw Exception('Failed to load services');
    }
  } catch (e) {
    print('Error fetching from API, trying cache ... $e');

    String? cached = box.read(cacheKey);
    if (cached != null) {
      List<dynamic> jsonData = json.decode(cached);
      return jsonData.map((item) => ServiceItem.fromJson(item)).toList();
    }

    throw Exception('No internet and no cached data available');
  }
}