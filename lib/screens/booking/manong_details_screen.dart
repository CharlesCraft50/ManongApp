import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:manong_application/main.dart';
import 'package:manong_application/models/manong.dart';
import 'package:manong_application/models/service_request.dart';
import 'package:manong_application/models/sub_service_item.dart';
import 'package:manong_application/screens/service_requests/route_tracking_screen.dart';
import 'package:manong_application/theme/colors.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:manong_application/utils/color_utils.dart';
import 'package:manong_application/utils/icon_mapper.dart';

class ManongDetailsScreen extends StatefulWidget {
  final LatLng? currentLatLng;
  final LatLng? manongLatLng;
  final String? manongName;
  final Manong? manong;
  final Color? iconColor;
  final ServiceRequest? serviceRequest;
  final SubServiceItem? subServiceItem;

  const ManongDetailsScreen({
    super.key,
    this.currentLatLng,
    this.manongLatLng,
    this.manongName,
    this.manong,
    this.iconColor,
    this.serviceRequest,
    this.subServiceItem,
  });

  @override
  State<ManongDetailsScreen> createState() => _ManongDetailsScreenState();
}

class _ManongDetailsScreenState extends State<ManongDetailsScreen> {
  final distance = latlong.Distance();
  final storage = FlutterSecureStorage();
  bool checked = false;
  String hideInstructionKey = 'hide_instruction_manong_details_screen';

  final instructions = [
    {
      'title': 'Meet your Manong',
      'description':
          'Check their name, photo, and details in the app before starting.',
      'imagePath': 'assets/icon/manong_verify_icon.png',
      'height': '120',
    },
    {
      'title': 'Confirm service',
      'description': 'Review the service type, rate, and estimated cost.',
      'imagePath': 'assets/icon/manong_service_icon.png',
      'height': '150',
    },
    {
      'title': 'Prepare your area',
      'description': 'Keep the workspace safe, clear, and accessible.',
      'imagePath': 'assets/icon/manong_prepare_icon.png',
      'height': '120',
    },
    {
      'title': 'Rate after',
      'description': 'Share honest ratings and feedback.',
      'imagePath': 'assets/icon/manong_review_icon.png',
      'height': '120',
    },
  ];

  @override
  void initState() {
    super.initState();
    showInstructionSheet(navigatorKey.currentContext!);
  }

  Widget _buildInstructionStep(String text, String imagePath, double height) {
    return SizedBox(
      width: 140,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColorScheme.royalBlueLight,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 50,
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  softWrap: true,
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            SizedBox(height: 4),
            SizedBox(
              height: 140,
              child: Center(child: Image.asset(imagePath, fit: BoxFit.contain)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showInstructionSheet(BuildContext context) async {
    String? hideInstructions = await storage.read(key: hideInstructionKey);
    if (hideInstructions == 'true') return;

    showModalBottomSheet(
      context: navigatorKey.currentContext!,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.only(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: 12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12),
                    Text(
                      'First time booking with Manong?',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Just a few reminders before you book!',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 24),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var item in instructions)
                            Container(
                              margin: EdgeInsets.only(right: 8),
                              child: _buildInstructionStep(
                                item['description']!,
                                item['imagePath']!,
                                double.parse(item['height'].toString()),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          activeColor: AppColorScheme.royalBlueMedium,
                          value: checked,
                          onChanged: (value) {
                            setState(() => checked = value!);

                            storage.write(
                              key: hideInstructionKey,
                              value: checked.toString(),
                            );
                          },
                        ),
                        const Text('Don\'t show this again'),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  double? _calculateDistance(Manong manong) {
    if (manong.appUser.latitude == null || manong.appUser.longitude == null) {
      return null;
    }

    return distance.as(
      latlong.LengthUnit.Meter,
      latlong.LatLng(
        widget.serviceRequest?.latitude ?? 0,
        widget.serviceRequest?.longitude ?? 0,
      ),
      latlong.LatLng(manong.appUser.latitude!, manong.appUser.longitude!),
    );
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()}m';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(1)}km';
    }
  }

  String _estimateTime(double meters, {double speedKmh = 30}) {
    // convert km/h → m/s
    final speedMs = speedKmh * 1000 / 3600;

    final seconds = meters / speedMs;
    final minutes = seconds / 60;

    if (minutes < 1) {
      return "${seconds.round()} sec";
    } else if (minutes < 60) {
      return "${minutes.round()} min";
    } else {
      final hours = minutes / 60;
      // ✅ if whole number, show as int, else 1 decimal
      return hours == hours.roundToDouble()
          ? "${hours.toInt()} hr"
          : "${hours.toStringAsFixed(1)} hr";
    }
  }

  // Future<void> _chooseManong(int serviceRequestId, int manongId) async {
  //   logger.info(
  //     'Choose Manong Started. Service Request Id: $serviceRequestId Manong Id: $manongId',
  //   );
  //   try {
  //     final response = await ManongApiService().chooseManong(
  //       serviceRequestId,
  //       manongId,
  //     );

  //     if (response != null) {
  //       final message = response['message']?.toString() ?? '';
  //       final success = response['success'] == true;

  //       if (response['warning'] != null &&
  //           response['warning'].toString().trim().isNotEmpty) {
  //         SnackBarUtils.showWarning(
  //           navigatorKey.currentContext!,
  //           response['warning'],
  //         );
  //       }

  //       SnackBarUtils.showInfo(navigatorKey.currentContext!, message);

  //       if (success) {
  //         Navigator.popAndPushNamed(
  //           navigatorKey.currentContext!,
  //           '/',
  //           arguments: {'index': 1},
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     logger.severe('Failed to choose manong $e');
  //   }
  // }

  Widget _buildBottomNav(double? meters, ScrollController scrollController) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ListView(
        controller: scrollController,
        children: [
          // -- Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // --- Time + Distance
          Row(
            children: [
              SizedBox(width: 10),
              Text(
                _estimateTime(meters ?? 0),
                style: TextStyle(fontSize: 18, color: Colors.red.shade700),
              ),
              SizedBox(width: 8),
              Text(
                '(${_formatDistance(meters ?? 0)})',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
              ),
              Spacer(),
            ],
          ),
          const SizedBox(height: 12),

          // --- Accept Button
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/booking-summary',
                      arguments: {
                        'serviceRequest': widget.serviceRequest!,
                        'manong': widget.manong!,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorScheme.royalBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Accept'),
                ),
              ),
            ],
          ),

          // -- More details
          Visibility(
            visible: true,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: Column(
              children: [
                const SizedBox(height: 3),
                Text(
                  "More details about the Manong...",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),

          // -- Manong Name
          Text(
            "Name",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          SizedBox(height: 4),

          Row(
            children: [
              Text(
                widget.manong?.appUser.name! ?? "No name",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              if (widget.manong?.profile!.isProfessionallyVerified == 1) ...[
                const SizedBox(width: 4),
                Icon(Icons.verified_rounded, size: 20, color: Colors.lightBlue),
              ],
            ],
          ),
          SizedBox(height: 8),

          // -- Status
          Text(
            "Status",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          SizedBox(height: 4),
          Wrap(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: getStatusColor(
                    widget.manong!.profile!.status,
                  ).withOpacity(0.1),
                  border: Border.all(
                    color: getStatusBorderColor(widget.manong!.profile!.status),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                child: Text(
                  widget.manong!.profile!.status,
                  style: TextStyle(
                    fontSize: 11,
                    color: getStatusBorderColor(widget.manong!.profile!.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (widget.manong!.profile!.specialities != null &&
              widget.manong!.profile!.specialities!.isNotEmpty) ...[
            // -- Specialities
            Text(
              "Specialities",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.manong!.profile!.specialities!.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        item.subServiceItem.title.contains(
                          widget.subServiceItem!.title,
                        )
                        ? Colors.amber.withOpacity(0.7)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(getIconFromName(item.subServiceItem.iconName)),
                      SizedBox(width: 4),
                      Text(
                        item.subServiceItem.title,
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meters = _calculateDistance(widget.manong!);

    return Material(
      child: Stack(
        children: [
          Positioned.fill(
            child: RouteTrackingScreen(
              currentLatLng: widget.currentLatLng,
              manongLatLng: widget.manongLatLng,
              manongName: widget.manongName,
            ),
          ),
          SafeArea(
            child: DraggableScrollableSheet(
              initialChildSize: 0.20,
              minChildSize: 0.05,
              maxChildSize: widget.manong!.profile!.specialities!.length >= 6
                  ? 0.7
                  : 0.5,
              snap: true,
              snapSizes: [
                0.20,
                widget.manong!.profile!.specialities!.length >= 6 ? 0.7 : 0.5,
              ],
              builder: (context, scrollController) {
                return _buildBottomNav(meters, scrollController);
              },
            ),
          ),
        ],
      ),
    );
  }
}
