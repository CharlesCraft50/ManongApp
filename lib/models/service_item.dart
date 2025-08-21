import 'package:manong_application/models/sub_service_item.dart';

class ServiceItem {
  final int id;
  final String title;
  final String description;
  final int priceMin;
  final int priceMax;
  final String iconName;
  final String iconColor;
  final int isActive;
  final List<SubServiceItem>? subServiceItems;

  ServiceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.priceMin,
    required this.priceMax,
    this.iconName = 'handyman',
    this.iconColor = '#3B82F6',
    required this.isActive,
    this.subServiceItems = const [],
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      priceMin: json['price_min'],
      priceMax: json['price_max'],
      iconName: json['icon_name'],
      iconColor: json['icon_color'],
      isActive: json['is_active'],
      subServiceItems:
          (json['sub_service_items'] as List<dynamic>?)
              ?.map((e) => SubServiceItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}
