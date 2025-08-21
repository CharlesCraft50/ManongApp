import 'package:flutter/material.dart';
import 'package:manong_application/models/service_request.dart';
import 'package:manong_application/theme/colors.dart';
import 'package:manong_application/utils/color_utils.dart';
import 'package:manong_application/widgets/icon_card.dart';

class ServiceRequestCard extends StatelessWidget {
  final ServiceRequest serviceRequestItem;
  final double? meters;
  final VoidCallback? onTap;

  const ServiceRequestCard({
    super.key,
    required this.serviceRequestItem,
    this.meters,
    this.onTap,
  });

  String _getStatusText() {
    final manongName = serviceRequestItem.manong?.name ?? '';
    final status = serviceRequestItem.status ?? 'Pending';

    if (manongName.isNotEmpty) {
      final firstName = manongName.split(' ').first;
      return 'Manong $firstName • $status';
    }

    return status;
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusBorderColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade700;
      case 'accepted':
        return Colors.blue.shade700;
      case 'completed':
        return Colors.green.shade700;
      case 'cancelled':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()}m';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(1)}km';
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceItemTitle =
        serviceRequestItem.serviceItem?.title ?? 'Unknown Service';
    final subServiceItemTitle =
        serviceRequestItem.subServiceItem?.title ?? 'Unknown Sub-Service';
    final urgencyLevelText =
        serviceRequestItem.urgencyLevel?.level ?? 'No urgency set';
    final iconName = serviceRequestItem.serviceItem?.iconName ?? 'help';
    final iconColorHex = serviceRequestItem.serviceItem?.iconColor ?? '#3B82F6';
    final manongName = serviceRequestItem.manong?.name ?? '';
    final manongFirstName = manongName.split(' ').first;
    final status = serviceRequestItem.status;

    return Card(
      color: AppColorScheme.backgroundGrey,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon section
              iconCard(
                iconColor: colorFromHex(iconColorHex),
                iconName: iconName,
              ),
              const SizedBox(width: 12),

              // Content section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Title
                    Text(
                      '$serviceItemTitle -> $subServiceItemTitle',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Status chip
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: _getStatusColor(status).withOpacity(0.1),
                        border: Border.all(
                          color: _getStatusBorderColor(status),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      child: Text(
                        _getStatusText(),
                        style: TextStyle(
                          fontSize: 11,
                          color: _getStatusBorderColor(status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // Urgency info
                    if (serviceRequestItem.manong?.id != null &&
                        serviceRequestItem.urgencyLevel?.time != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '$urgencyLevelText (${serviceRequestItem.urgencyLevel!.time})',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Distance
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Icon(
                    Icons.location_on,
                    size: 24,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 4),
                  meters != null
                      ? Text(
                          _formatDistance(meters!),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : Text(
                          'N/A',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
