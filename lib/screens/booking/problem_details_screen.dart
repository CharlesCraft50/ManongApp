import 'dart:io';

import 'package:flutter/material.dart';
import 'package:manong_application/api/manong_api_service.dart';
import 'package:manong_application/constants/steps_labels.dart';
import 'package:manong_application/main.dart';
import 'package:manong_application/models/app_step_flows.dart';
import 'package:manong_application/models/service_request.dart';
import 'package:manong_application/models/service_item.dart';
import 'package:manong_application/models/sub_service_item.dart';
import 'package:manong_application/models/urgency_level.dart';
import 'package:manong_application/theme/colors.dart';
import 'package:manong_application/widgets/card_container.dart';
import 'package:manong_application/widgets/image_picker_card.dart';
import 'package:manong_application/widgets/map_preview.dart';
import 'package:manong_application/widgets/step_appbar.dart';
import 'package:manong_application/widgets/step_indicator.dart';
import 'package:manong_application/widgets/urgency_selector.dart';

class ProblemDetailsScreen extends StatefulWidget {
  final ServiceItem serviceItem;
  final SubServiceItem subServiceItem;
  final Color iconColor;

  const ProblemDetailsScreen({
    super.key,
    required this.serviceItem,
    required this.subServiceItem,
    required this.iconColor,
  });

  @override
  State<ProblemDetailsScreen> createState() => _ProblemDetailsScreenState();
}

class _ProblemDetailsScreenState extends State<ProblemDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  int _activeUrgencyLevel = 0;
  bool _isLoading = false;
  String? _locationName;
  bool isOtherService = false;
  late List<File> _images;
  late SubServiceItem selectedSubServiceItem;
  late ServiceItem selectedServiceItem;
  double? _latitude;
  double? _longitude;
  late ManongApiService manongApiService;

  // Text Controller
  late TextEditingController _serviceNameController;
  late TextEditingController _serviceDetailsController;

  static const List<UrgencyLevel> _urgencyLevels = [
    UrgencyLevel(id: 0, level: 'Normal', time: '2-4 hours'),
    UrgencyLevel(id: 1, level: 'Urgent', time: '1-2 hours', price: 20.00),
    UrgencyLevel(id: 2, level: 'Emergency', time: '30-60 mins', price: 30.00),
  ];

  void _setActiveUrgencyLevel(int index) {
    setState(() {
      _activeUrgencyLevel = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _images = <File>[];
    selectedSubServiceItem = widget.subServiceItem;
    selectedServiceItem = widget.serviceItem;
    isOtherService = selectedSubServiceItem.title == "Other Service";
    _serviceNameController = TextEditingController();
    _serviceDetailsController = TextEditingController();
    manongApiService = ManongApiService();
  }

  void _findAvailableManongs() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(
            'Home Address is not set. Please enable your Location service.',
          ),
        ),
      );
      return;
    }

    if (_images.isEmpty) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Please upload at least one image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final serviceRequest = ServiceRequest(
      serviceItemId: selectedServiceItem.id,
      subServiceItemId: selectedSubServiceItem.id,
      urgencyLevelIndex: _activeUrgencyLevel,
      images: _images,
      latitude: _latitude!,
      longitude: _longitude!,
    );

    try {
      final response = await manongApiService.uploadServiceRequest(
        serviceRequest,
      );
      if (response != null) {
        if (response['warning'] != null &&
            response['warning'].toString().trim().isNotEmpty) {
          ScaffoldMessenger.of(
            navigatorKey.currentContext!,
          ).showSnackBar(SnackBar(content: Text(response['warning'])));
          return;
        }

        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(content: Text('Problem details uploaded successfully!')),
        );
      } else {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(content: Text('Failed to upload problem details.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        navigatorKey.currentContext!,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stepFlow = AppStepFlows.serviceBooking;

    int currentStep = 2;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: StepAppbar(
        title: 'Details',
        subtitle:
            '${selectedServiceItem.title} - ${selectedSubServiceItem.title}',
        currentStep: currentStep,
        totalSteps: stepFlow.totalSteps,
        trailing: GestureDetector(
          onTap: () {},
          child: Icon(Icons.bookmark_add_outlined),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StepIndicator(
                        totalSteps: stepFlow.totalSteps,
                        currentStep: currentStep,
                        stepLabels: StepsLabels.serviceBooking,
                        padding: EdgeInsetsGeometry.symmetric(vertical: 32),
                      ),

                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          children: [
                            CardContainer(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_pin),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Home Address',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                MapPreview(
                                  enableMarkers: true,
                                  onLocationResult: (result) {
                                    setState(() {
                                      _locationName = result.locationName;
                                    });
                                  },
                                  onPosition: (latitude, longitude) {
                                    setState(() {
                                      _latitude = latitude;
                                      _longitude = longitude;
                                    });
                                  },
                                ),

                                const SizedBox(height: 12),

                                Text(_locationName ?? 'Loading...'),

                                const SizedBox(height: 24),

                                if (isOtherService) ...[
                                  Container(
                                    margin: EdgeInsets.only(bottom: 14),
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value!.trim().isEmpty) {
                                          return "Service name cannot be empty.";
                                        } else {
                                          return null;
                                        }
                                      },
                                      controller: _serviceNameController,
                                      maxLength: 50,
                                      decoration: InputDecoration(
                                        labelText: 'Service Name *',
                                        labelStyle: TextStyle(
                                          color: Colors.red,
                                        ),
                                        hintText:
                                            'Please specify the service you need',
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColorScheme.royalBlue,
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],

                                TextFormField(
                                  controller: _serviceDetailsController,
                                  decoration: InputDecoration(
                                    labelText: 'Service Details (Optional)',
                                    labelStyle: TextStyle(
                                      color: AppColorScheme.royalBlue,
                                    ),
                                    hintText:
                                        'Please describe what needs to be fixed or installed… (e.g. faucet leak, no water)',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: AppColorScheme.royalBlue,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  maxLines: 5,
                                  minLines: 3,
                                  keyboardType: TextInputType.multiline,
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            CardContainer(
                              children: [
                                Text(
                                  'Urgency Level',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                UrgencySelector(
                                  levels: _urgencyLevels,
                                  activeIndex: _activeUrgencyLevel,
                                  onSelected: _setActiveUrgencyLevel,
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            CardContainer(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Upload Photos',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    Text(
                                      '${_images.length}/3',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  'Help us understand the problem better',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                ImagePickerCard(
                                  onImageSelect: (List<File> images) {
                                    if (images.isNotEmpty &&
                                        images.length <= 3) {
                                      setState(() {
                                        _images = images;
                                      });
                                    } else if (images.length > 3) {
                                      ScaffoldMessenger.of(
                                        navigatorKey.currentContext!,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'You can upload a maximum of 3 images',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                offset: Offset(0, -4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorScheme.royalBlue,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isLoading ? null : _findAvailableManongs,
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "SEARCH FOR MANONG NEAR YOU",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _serviceDetailsController.dispose();
    super.dispose();
  }
}
