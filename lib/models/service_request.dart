import 'dart:io';

import 'package:manong_application/models/app_user.dart';
import 'package:manong_application/models/payment_status.dart';
import 'package:manong_application/models/service_item.dart';
import 'package:manong_application/models/sub_service_item.dart';
import 'package:manong_application/models/urgency_level.dart';

class ServiceRequest {
  final int? id;
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
  final double? total;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final PaymentStatus? paymentStatus;
  final ServiceItem? serviceItem;
  final SubServiceItem? subServiceItem;
  final UrgencyLevel? urgencyLevel;
  final AppUser? manong;

  ServiceRequest({
    this.id,
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
    this.total,
    this.createdAt,
    this.updatedAt,
    this.paymentStatus,
    this.serviceItem,
    this.subServiceItem,
    this.urgencyLevel,
    this.manong,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] != null ? json['id'] as int : null,
      serviceItemId: int.tryParse(json['serviceItemId'].toString()) ?? 0,
      subServiceItemId: int.tryParse(json['subServiceItemId'].toString()) ?? 0,
      manongId: json['manongId'] != null
          ? int.tryParse(json['manongId'].toString())
          : null,
      otherServiceName: json['otherServiceName'],
      serviceDetails: json['serviceDetails'],
      urgencyLevelIndex: int.tryParse(json['urgencyLevelId'].toString()) ?? 0,
      images: json['imagesPath'] == null
          ? []
          : (json['imagesPath'] is List
                ? (json['imagesPath'] as List)
                      .map((path) => File(path.toString()))
                      .toList()
                : [File(json['imagesPath'].toString())]),
      latitude: (json['latitude'] is num)
          ? (json['latitude'] as num).toDouble()
          : double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: (json['longitude'] is num)
          ? (json['longitude'] as num).toDouble()
          : double.tryParse(json['longitude'].toString()) ?? 0.0,
      notes: json['notes'],
      rating: json['rating'],
      status: json['status'],
      total: json['total'],
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString() == json['paymentStatus'].toString(),
        orElse: () => PaymentStatus.unpaid,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
      serviceItem: json['serviceItem'] != null
          ? ServiceItem.fromJson(json['serviceItem'])
          : null,
      subServiceItem: json['subServiceItem'] != null
          ? SubServiceItem.fromJson(json['subServiceItem'])
          : null,
      urgencyLevel: json['urgencyLevel'] != null
          ? UrgencyLevel.fromJson(json['urgencyLevel'])
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

  @override
  String toString() {
    return 'ServiceRequest('
        'id: $id, '
        'serviceItemId: $serviceItemId, '
        'subServiceItemId: $subServiceItemId, '
        'manongId: $manongId, '
        'otherServiceName: $otherServiceName, '
        'serviceDetails: $serviceDetails, '
        'urgencyLevelIndex: $urgencyLevelIndex, '
        'images: ${images.map((f) => f.path).toList()}, '
        'latitude: $latitude, '
        'longitude: $longitude, '
        'notes: $notes, '
        'rating: $rating, '
        'status: $status, '
        'total: $total, '
        'paymentStatus: $paymentStatus, '
        'paymentStatus: $createdAt, '
        'paymentStatus: $updatedAt, '
        'serviceItem: $serviceItem, '
        'subServiceItem: $subServiceItem, '
        'urgencyLevel: $urgencyLevel, '
        'manong: $manong'
        ')';
  }
}
