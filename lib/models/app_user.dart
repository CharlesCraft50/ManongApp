import 'package:manong_application/models/payment_method.dart';
import 'package:manong_application/models/user_payment_method.dart';

class AppUser {
  final int id;
  final String? name;
  final String? email;
  final String role;
  final bool isVerified;
  final String phone;
  final double? latitude;
  final double? longitude;
  final String? profilePhoto;
  final List<UserPaymentMethod>? userPaymentMethod;

  AppUser({
    required this.id,
    this.name,
    this.email,
    required this.role,
    required this.isVerified,
    required this.phone,
    this.latitude,
    this.longitude,
    this.profilePhoto,
    this.userPaymentMethod,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      isVerified: json['isVerified'],
      phone: json['phone'],
      latitude: json['latitude'] != null
          ? double.parse(json['latitude'])
          : null,
      longitude: json['longitude'] != null
          ? double.parse(json['longitude'])
          : null,
      profilePhoto: json['profilePhoto'],
      userPaymentMethod:
          (json['userPaymentMethods'] as List<dynamic>?)
              ?.map((s) => UserPaymentMethod.fromJson(s))
              .toList() ??
          [],
    );
  }

  @override
  String toString() {
    return 'AppUser{id: $id, name: $name, email: $email, role: $role, '
        'isVerified: $isVerified, phone: $phone, latitude: $latitude, '
        'longitude: $longitude, profilePhoto: $profilePhoto, '
        'userPaymentMethod: ${userPaymentMethod?.map((e) => e.toString()).toList()}}';
  }
}
