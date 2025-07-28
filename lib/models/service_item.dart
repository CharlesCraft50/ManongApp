class ServiceItem {
  final int id;
  final String title;
  final String description;
  final int priceMin;
  final int priceMax;
  final String iconName;
  final int isActive;

  ServiceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.priceMin,
    required this.priceMax,
    required this.iconName,
    required this.isActive,
  });

 factory ServiceItem.fromJson(Map<String, dynamic> json) {
  return ServiceItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      priceMin: json['price_min'],
      priceMax: json['price_max'],
      iconName: json['icon_name'],
      isActive: json['is_active'],
    );
 }
}