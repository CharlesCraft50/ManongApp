import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/service_item.dart';

Future <List<ServiceItem>> fetchServiceItems() async {
  final baseUrl = Uri.parse('${dotenv.env['APP_URL']}/service-items');
  final response = await http.get(baseUrl); 

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((item) => ServiceItem.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load services');
  }
}