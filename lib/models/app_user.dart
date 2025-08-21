class AppUser {
  final int id;
  final String? name;
  final String? email;
  final String role;
  final int isVerified;
  final String phone;
  final double? latitude;
  final double? longitude;

  AppUser({
    required this.id,
    this.name,
    this.email,
    required this.role,
    required this.isVerified,
    required this.phone,
    this.latitude,
    this.longitude,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      isVerified: json['is_verified'],
      phone: json['phone'],
      latitude: json['latitude'] != null
          ? double.parse(json['latitude'])
          : null,
      longitude: json['latitude'] != null
          ? double.parse(json['longitude'])
          : null,
    );
  }
}
