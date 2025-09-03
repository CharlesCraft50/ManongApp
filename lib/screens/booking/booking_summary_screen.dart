import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:manong_application/api/auth_service.dart';
import 'package:manong_application/api/service_request_api_service.dart';
import 'package:manong_application/constants/steps_labels.dart';
import 'package:manong_application/main.dart';
import 'package:manong_application/models/app_step_flows.dart';
import 'package:manong_application/models/app_user.dart';
import 'package:manong_application/models/manong.dart';
import 'package:manong_application/models/service_request.dart';
import 'package:manong_application/models/step_flow.dart';
import 'package:manong_application/theme/colors.dart';
import 'package:manong_application/utils/snackbar_utils.dart';
import 'package:manong_application/widgets/card_container.dart';
import 'package:manong_application/widgets/error_state_widget.dart';
import 'package:manong_application/widgets/image_dialog.dart';
import 'package:manong_application/widgets/label_value_row.dart';
import 'package:manong_application/widgets/manong_list_card.dart';
import 'package:manong_application/widgets/my_app_bar.dart';
import 'package:manong_application/widgets/price_tag.dart';
import 'package:manong_application/widgets/selectable_item_widget.dart';
import 'package:manong_application/widgets/step_indicator.dart';

class BookingSummaryScreen extends StatefulWidget {
  final ServiceRequest serviceRequest;
  final Manong manong;

  const BookingSummaryScreen({
    super.key,
    required this.serviceRequest,
    required this.manong,
  });
  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  late Logger logger;
  final baseImageUrl = dotenv.env['APP_URL'];
  late ServiceRequest serviceRequest;
  late Manong manong;
  late StepFlow stepFlow;
  late AuthService authService;
  late ServiceRequestApiService serviceRequestApiService;
  AppUser? user;
  ServiceRequest? userServiceRequest;
  bool isLoading = true;
  bool isButtonLoading = false;
  String? _error;
  final double serviceTaxRate = 0.12;
  bool _toggledContainer = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _totalsCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    initializeComponents();
    _initializeData();
  }

  void initializeComponents() {
    logger = Logger('BookingSummaryScreen');
    serviceRequest = widget.serviceRequest;
    manong = widget.manong;
    stepFlow = AppStepFlows.serviceBooking;
    authService = AuthService();
    serviceRequestApiService = ServiceRequestApiService();
  }

  Future<void> _initializeData() async {
    await _fetchUserServiceRequest();
    await _fetchUser();
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

  Future<void> _fetchUserServiceRequest() async {
    setState(() {
      isLoading = true;
      _error = null;
    });

    try {
      final serviceRequestId = serviceRequest.id;
      if (serviceRequestId == null) {
        throw Exception('Service request ID is null');
      }

      final response = await serviceRequestApiService.fetchUserServiceRequest(
        serviceRequestId,
      );

      logger.info(
        'message : ${response?.subServiceItem?.fee?.toString() ?? ''}',
      );

      if (!mounted) return;
      setState(() {
        isLoading = false;
        userServiceRequest = response;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        _error = e.toString();
      });

      logger.severe('Error fetching user service request $_error');
    }
  }

  Widget _buildManongDetails() {
    final manongName = manong.appUser.name;
    final manongProfile = manong.profile;

    if (manongName == null || manongProfile == null) {
      return const SizedBox.shrink();
    }

    return CardContainer(
      children: [
        ManongListCard(
          name: manongName,
          iconColor: Colors.blue,
          onTap: () {},
          isProfessionallyVerified: manongProfile.isProfessionallyVerified,
          status: manongProfile.status,
        ),
      ],
    );
  }

  Widget _buildUrgentLevel() {
    final urgencyLevel = userServiceRequest?.urgencyLevel;
    if (urgencyLevel == null) {
      return const SizedBox.shrink();
    }

    return CardContainer(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Urgency Level',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Edit',
              style: TextStyle(fontSize: 14, color: Colors.blue),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Material(
          color: Colors.white60,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      urgencyLevel.level,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      urgencyLevel.time,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),

                Text(
                  urgencyLevel.price != null
                      ? '₱ ${urgencyLevel.price!.toStringAsFixed(2)}'
                      : '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showImageDialog(String image) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      builder: (_) => ImageDialog(imageString: image),
    );
  }

  Widget _buildUploadedPhotos() {
    final images = userServiceRequest?.images;
    if (images == null || images.isEmpty) {
      return const SizedBox.shrink();
    }

    return CardContainer(
      children: [
        const Text(
          'Uploaded Images',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColorScheme.royalBlueLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SingleChildScrollView(
                controller: ScrollController(),
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: images.map((file) {
                    final imageUrl = baseImageUrl != null
                        ? '$baseImageUrl/${file.path.replaceAll("\\", "/")}'
                        : '';

                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () {
                            if (imageUrl.isNotEmpty) {
                              _showImageDialog(imageUrl);
                            }
                          },
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.broken_image),
                                  height: 150,
                                  width: 100,
                                )
                              : const Icon(Icons.broken_image, size: 100),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
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

  Widget _buildPaymentMethod() {
    return CardContainer(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Payment Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: _goToPaymentMethodsScreen,
              child: const Text(
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
        const SizedBox(height: 4),
        SizedBox(
          width:
              MediaQuery.of(context).size.width *
              0.8, // Use context instead of navigatorKey
          child: const Text(
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
                onTap: () {},
                trailing: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorScheme.royalBlueLight,
                    foregroundColor: AppColorScheme.royalBlueDark,
                  ),
                  child: const Text('Add'),
                ),
              ),

              SelectableItemWidget(
                title: _getPaymentMethodName(),
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

  String _getPaymentMethodName() {
    final userPaymentMethods = user?.userPaymentMethod;
    if (userPaymentMethods == null || userPaymentMethods.isEmpty) {
      return 'No payment method';
    }

    try {
      final defaultPaymentMethod = userPaymentMethods.firstWhere(
        (p) => p.isDefault == 1,
        orElse: () => userPaymentMethods.first,
      );
      return defaultPaymentMethod.paymentMethod.name;
    } catch (e) {
      return 'No payment method';
    }
  }

  double _calculateSubTotal() {
    double total = 0;

    if (userServiceRequest == null) return 0;

    if (userServiceRequest?.subServiceItem?.fee != null) {
      total += userServiceRequest!.subServiceItem!.fee!.toDouble();
    }

    if (userServiceRequest?.urgencyLevel?.price != null) {
      total += userServiceRequest!.urgencyLevel!.price!.toDouble();
    }

    return total;
  }

  double _calculateServiceTaxAmount() {
    return _calculateSubTotal() * serviceTaxRate;
  }

  double _calculateTotal() {
    double total = 0;

    if (userServiceRequest == null) return 0;

    if (userServiceRequest?.subServiceItem?.fee != null) {
      total += userServiceRequest!.subServiceItem!.fee!.toDouble();
    }

    if (userServiceRequest?.urgencyLevel?.price != null) {
      total += userServiceRequest!.urgencyLevel!.price!.toDouble();
    }

    return total + _calculateServiceTaxAmount();
  }

  Widget _buildTotals() {
    if (userServiceRequest == null) {
      return const SizedBox.shrink();
    }
    return CardContainer(
      key: _totalsCardKey,
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 600),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _toggledContainer
                ? AppColorScheme.royalBlueLight
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Service Request Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Divider(
                color: Colors.grey,
                thickness: 1,
                indent: 20,
                endIndent: 20,
              ),
              Text(
                'Service: ${userServiceRequest?.subServiceItem?.title}',
                style: TextStyle(fontSize: 14),
              ),
              LabelValueRow(
                label: 'Base Fee:',
                valueWidget: userServiceRequest?.subServiceItem?.fee != null
                    ? PriceTag(
                        price: userServiceRequest!.subServiceItem!.fee!
                            .toDouble(),
                      )
                    : null,
              ),
              LabelValueRow(
                label: 'Urgency Fee:',
                valueWidget: userServiceRequest?.urgencyLevel?.level != null
                    ? PriceTag(
                        price: userServiceRequest!.urgencyLevel!.price!
                            .toDouble(),
                      )
                    : null,
              ),
              Divider(
                color: Colors.grey,
                thickness: 1,
                indent: 20,
                endIndent: 20,
              ),
              LabelValueRow(
                label: 'Subtotal',
                valueWidget: PriceTag(price: _calculateSubTotal()),
              ),
              LabelValueRow(
                label:
                    'Service Tax (${(serviceTaxRate * 100).toStringAsFixed(0)})',
                valueWidget: PriceTag(
                  price: double.parse(
                    _calculateServiceTaxAmount().toStringAsFixed(2),
                  ),
                ),
              ),
              Divider(
                color: Colors.grey,
                thickness: 1,
                indent: 20,
                endIndent: 20,
              ),
              LabelValueRow(
                label: 'Total To Pay:',
                valueWidget: PriceTag(price: _calculateTotal()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingSummary() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StepIndicator(
              totalSteps: stepFlow.totalSteps,
              currentStep: 4,
              stepLabels: StepsLabels.serviceBooking,
              padding: const EdgeInsets.symmetric(vertical: 32),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildManongDetails(),
                  const SizedBox(height: 16),
                  _buildUrgentLevel(),
                  const SizedBox(height: 16),
                  _buildUploadedPhotos(),
                  const SizedBox(height: 16),
                  _buildPaymentMethod(),
                  const SizedBox(height: 16),
                  _buildTotals(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void toggleTotalCard() {
    setState(() {
      _toggledContainer = true;
    });

    final context = _totalsCardKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: Duration(milliseconds: 600),
        curve: Curves.easeOut,
      );
    }

    Future.delayed(Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _toggledContainer = false;
      });
    });
  }

  Widget _buildState() {
    if (_error != null) {
      return ErrorStateWidget(
        errorText: _error.toString(),
        onPressed: _fetchUserServiceRequest,
      );
    }

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColorScheme.royalBlue),
      );
    }

    return _buildBookingSummary();
  }

  Widget _buildTotalAreaBottom() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Total',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Text(
              '(incl. fees and tax)',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            Spacer(),
            PriceTag(
              price: _calculateTotal(),
              textStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        GestureDetector(
          onTap: toggleTotalCard,
          child: Text(
            'See Summary',
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: 12,
          top: 20,
        ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),

        child: Column(
          spacing: 8,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTotalAreaBottom(),
            Divider(
              color: Colors.grey,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isButtonLoading ? null : _handleConfirmPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorScheme.royalBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isButtonLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Confirm & Pay',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleConfirmPayment() async {
    setState(() {
      isButtonLoading = true;
    });

    final currentUserServiceRequest = userServiceRequest;
    final serviceRequestId = currentUserServiceRequest?.id;
    final manongUserId = manong.appUser.id;

    if (serviceRequestId == null || manongUserId == null) {
      setState(() {
        isButtonLoading = false;
      });
      if (mounted) {
        SnackBarUtils.showError(context, 'Missing required data for payment');
      }
      return;
    }

    try {
      final response = await serviceRequestApiService.chooseManong(
        serviceRequestId,
        manongUserId,
      );

      if (!mounted) return;
      setState(() {
        isButtonLoading = false;
      });

      if (response != null && response.isNotEmpty) {
        final warning = response['warning'];
        if (warning != null && warning.toString().trim().isNotEmpty) {
          final context = navigatorKey.currentContext;
          if (context != null) {
            SnackBarUtils.showWarning(context, warning.toString());
          }
          return;
        }

        final context = navigatorKey.currentContext;
        if (context != null) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      } else {
        logger.warning('Cannot choose manong. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isButtonLoading = false;
      });
      SnackBarUtils.showError(context, 'Payment failed ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorScheme.backgroundGrey,
      appBar: myAppBar(
        title: 'Booking Summary',
        trailing: GestureDetector(
          onTap: () {},
          child: const Icon(Icons.delete),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: _buildState(),
      bottomNavigationBar: _buildConfirmButton(),
    );
  }
}
