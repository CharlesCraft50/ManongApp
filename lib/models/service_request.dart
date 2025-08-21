import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:manong_application/models/app_user.dart';
import 'package:manong_application/models/service_item.dart';
import 'package:manong_application/models/sub_service_item.dart';
import 'package:manong_application/models/urgency_level.dart';

class ServiceRequest {
  final int serviceItemId;
  final int subServiceItemId;
  final int? manongId;
  final String? otherServiceName;
  final String? serviceDetails;
  final int urgencyLevelIndex;
  final List<File> images;
  final double latitude;
  final double longitude;
  final String? notes;
  final int? rating;
  final String? status;
  final ServiceItem? serviceItem;
  final SubServiceItem? subServiceItem;
  final UrgencyLevel? urgencyLevel;
  final AppUser? manong;

  ServiceRequest({
    required this.serviceItemId,
    required this.subServiceItemId,
    this.manongId,
    this.otherServiceName,
    this.serviceDetails,
    required this.urgencyLevelIndex,
    required this.images,
    required this.latitude,
    required this.longitude,
    this.notes,
    this.rating,
    this.status,
    this.serviceItem,
    this.subServiceItem,
    this.urgencyLevel,
    this.manong,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      serviceItemId: json['service_item_id'],
      subServiceItemId: json['sub_service_item_id'],
      manongId: json['manong_id'],
      otherServiceName: json['other_service_name'],
      serviceDetails: json['service_details'],
      urgencyLevelIndex: json['urgency_level_id'] ?? 0,
      images:
          (json['images_path'] as List<dynamic>?)
              ?.map((path) => File(path.toString()))
              .toList() ??
          [],
      latitude: double.parse(json['latitude']),
      longitude: double.parse(json['longitude']),
      notes: json['notes'],
      rating: json['rating'],
      status: json['status'],
      serviceItem: json['service_item'] != null
          ? ServiceItem.fromJson(json['service_item'])
          : null,
      subServiceItem: json['sub_service_item'] != null
          ? SubServiceItem.fromJson(json['sub_service_item'])
          : null,
      urgencyLevel: json['urgency_level'] != null
          ? UrgencyLevel.fromJson(json['urgency_level'])
          : null,
      manong: json['manong'] != null ? AppUser.fromJson(json['manong']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_item_id': serviceItemId,
      'sub_service_item_id': subServiceItemId,
      'manong_id': manongId,
      'other_service_name': otherServiceName,
      'service_details': serviceDetails,
      'urgency_level_id': urgencyLevelIndex,
      'images_path': images.map((file) => file.path).toList(),
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
      'rating': rating,
    };
  }
}
