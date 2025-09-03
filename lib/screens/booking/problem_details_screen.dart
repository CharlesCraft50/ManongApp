import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:manong_application/api/auth_service.dart';
import 'package:manong_application/api/service_request_api_service.dart';
import 'package:manong_application/constants/steps_labels.dart';
import 'package:manong_application/main.dart';
import 'package:manong_application/models/app_step_flows.dart';
import 'package:manong_application/models/app_user.dart';
import 'package:manong_application/models/service_request.dart';
import 'package:manong_application/models/service_item.dart';
import 'package:manong_application/models/step_flow.dart';
import 'package:manong_application/models/sub_service_item.dart';
import 'package:manong_application/models/urgency_level.dart';
import 'package:manong_application/theme/colors.dart';
import 'package:manong_application/utils/error_helper.dart';
import 'package:manong_application/utils/snackbar_utils.dart';
import 'package:manong_application/widgets/card_container.dart';
import 'package:manong_application/widgets/error_state_widget.dart';
import 'package:manong_application/widgets/image_picker_card.dart';
import 'package:manong_application/widgets/map_preview.dart';
import 'package:manong_application/widgets/selectable_item_widget.dart';
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
  late Logger logger;
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
  late ServiceRequestApiService manongApiService;

  // Text Controller
  late TextEditingController _serviceNameController;
  late TextEditingController _serviceDetailsController;
  late AuthService authService;
  AppUser? user;
  bool isLoading = true;
  String? _error;
  late StepFlow stepFlow;
  int currentStep = 2;

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
    initializedComponents();
    _fetchUser();
  }

  void initializedComponents() {
    logger = Logger('ProblemDetailsScreen');
    authService = AuthService();
    stepFlow = AppStepFlows.serviceBooking;
    _images = <File>[];
    selectedSubServiceItem = widget.subServiceItem;
    selectedServiceItem = widget.serviceItem;
    isOtherService = selectedSubServiceItem.title == "Other Service";
    _serviceNameController = TextEditingController();
    _serviceDetailsController = TextEditingController();
    manongApiService = ServiceRequestApiService();
  }

  void _findAvailableManongs() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_latitude == null || _longitude == null) {
      SnackBarUtils.showWarning(
        navigatorKey.currentContext!,
        'Home Address is not set. Please enable your Location service.',
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

    Map<String, dynamic>? response;

    try {
      response = await manongApiService.uploadServiceRequest(serviceRequest);

      if (response != null) {
        if (response['warning'] != null &&
            response['warning'].toString().trim().isNotEmpty) {
          SnackBarUtils.showWarning(
            navigatorKey.currentContext!,
            response['warning'],
          );

          return;
        }

        SnackBarUtils.showInfo(
          navigatorKey.currentContext!,
          'Problem details uploaded! Please choose your Manong.',
        );
      } else {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(content: Text('Failed to upload problem details.')),
        );
      }
    } catch (e) {
      String errorMessage = ErrorHelper.extractErrorMessage(e.toString());

      SnackBarUtils.showWarning(navigatorKey.currentContext!, errorMessage);

      logger.severe('Upload error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });

      if (response != null &&
          response['success'] == true &&
          response['data'] != null) {
        final serviceRequest = ServiceRequest.fromJson(response['data']);
        if (serviceRequest.manongId != null) {
          // If Manong is already assigned, go home
          Navigator.pushNamedAndRemoveUntil(
            navigatorKey.currentContext!,
            '/',
            (Route<dynamic> route) => false,
            arguments: {'index': 1},
          );
        } else {
          // Otherwise, show Manong list
          if (response['duplicate'] == true || response['warning'] == null) {
            Navigator.pushNamed(
              navigatorKey.currentContext!,
              '/manong-list',
              arguments: {
                'serviceRequest': response['data'],
                'subServiceItem': selectedSubServiceItem,
              },
            );
          }
        }
      }
    }
  }

  void _goToPaymentMethodsScreen() {
    Navigator.pushNamed(
      context,
      '/payment-methods',
      arguments: {
        'selectedIndex':
            (user?.userPaymentMethod != null &&
                user!.userPaymentMethod!.isNotEmpty)
            ? user!.userPaymentMethod!
                      .firstWhere(
                        (p) => p.isDefault == 1,
                        orElse: () => user!.userPaymentMethod!.first,
                      )
                      .paymentMethod
                      .id -
                  1
            : null,
      },
    );
  }

  Widget _buildPaymentDetailsArea() {
    return CardContainer(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Payment Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: _goToPaymentMethodsScreen,
              child: Text(
                'See All',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        SizedBox(
          width: MediaQuery.of(navigatorKey.currentContext!).size.width * 0.8,
          child: Text(
            'Cashless payments are faster, safer, and preferred by Manongs.',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),

        const SizedBox(height: 4),

        GestureDetector(
          onTap: _goToPaymentMethodsScreen,
          child: Column(
            children: [
              SelectableItemWidget(
                title: 'Cards',
                icon: Icons.credit_card,
                onTap: _goToPaymentMethodsScreen,
                trailing: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorScheme.royalBlueLight,
                    foregroundColor: AppColorScheme.royalBlueDark,
                  ),
                  child: Text('Add'),
                ),
              ),

              SelectableItemWidget(
                title:
                    (user?.userPaymentMethod != null &&
                        user!.userPaymentMethod!.isNotEmpty)
                    ? user!.userPaymentMethod!
                          .firstWhere(
                            (p) => p.isDefault == 1,
                            orElse: () => user!.userPaymentMethod!.first,
                          )
                          .paymentMethod
                          .name
                    : 'No payment method',
                icon: Icons.money,
                onTap: () {},
                selected: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _fetchUser() async {
    setState(() {
      isLoading = true;
      _error = null;
    });

    try {
      final response = await authService.getMyProfile();

      if (!mounted) return;
      setState(() {
        isLoading = false;
        _error = null;
        user = response;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        _error = e.toString();
      });
      logger.severe('Error fetching user $_error');
    }
  }

  Widget _buildHomeAddress() {
    return CardContainer(
      children: [
        Row(
          children: [
            Icon(Icons.location_pin),
            const SizedBox(width: 8),
            Text(
              'Home Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                labelStyle: TextStyle(color: Colors.red),
                hintText: 'Please specify the service you need',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
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
            ),
          ),
        ],

        TextFormField(
          controller: _serviceDetailsController,
          decoration: InputDecoration(
            labelText: 'Service Details (Optional)',
            labelStyle: TextStyle(color: AppColorScheme.royalBlue),
            hintText:
                'Please describe what needs to be fixed or installed… (e.g. faucet leak, no water)',
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColorScheme.royalBlue, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          maxLines: 5,
          minLines: 3,
          keyboardType: TextInputType.multiline,
        ),
      ],
    );
  }

  Widget _buildUrgencyLevels() {
    return CardContainer(
      children: [
        Text(
          'Urgency Level',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        UrgencySelector(
          levels: _urgencyLevels,
          activeIndex: _activeUrgencyLevel,
          onSelected: _setActiveUrgencyLevel,
        ),
      ],
    );
  }

  Widget _buildUploadPhotos() {
    return CardContainer(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upload Photos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            Text(
              '${_images.length}/3',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),

        const SizedBox(height: 4),

        Text(
          'Help us understand the problem better',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),

        const SizedBox(height: 12),

        ImagePickerCard(
          onImageSelect: (List<File> images) {
            if (images.isNotEmpty && images.length <= 3) {
              setState(() {
                _images = images;
              });
            } else if (images.length > 3) {
              ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
                SnackBar(content: Text('You can upload a maximum of 3 images')),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildProblemDetails() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StepIndicator(
              totalSteps: stepFlow.totalSteps,
              currentStep: currentStep,
              stepLabels: StepsLabels.serviceBooking,
              padding: const EdgeInsetsGeometry.symmetric(vertical: 32),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHomeAddress(),
                  SizedBox(height: 12),
                  _buildUrgencyLevels(),
                  SizedBox(height: 16),
                  _buildUploadPhotos(),
                  SizedBox(height: 16),
                  _buildPaymentDetailsArea(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildState() {
    if (_error != null) {
      return ErrorStateWidget(
        errorText: 'Error. Please Try again.',
        onPressed: _fetchUser,
      );
    }

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColorScheme.royalBlue),
      );
    }

    return _buildProblemDetails();
  }

  Widget _buildSearchManongButton() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: 12,
          top: 20,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              offset: const Offset(0, -4),
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
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: Form(key: _formKey, child: _buildState()),

      bottomNavigationBar: _buildSearchManongButton(),
    );
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _serviceDetailsController.dispose();
    super.dispose();
  }
}
