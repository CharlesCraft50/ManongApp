import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:manong_application/api/payment_method_api_service.dart';
import 'package:manong_application/api/user_payment_method_api_service.dart';
import 'package:manong_application/main.dart';
import 'package:manong_application/models/payment_method.dart';
import 'package:manong_application/theme/colors.dart';
import 'package:manong_application/utils/snackbar_utils.dart';
import 'package:manong_application/widgets/error_state_widget.dart';
import 'package:manong_application/widgets/my_app_bar.dart';
import 'package:manong_application/widgets/selectable_icon_list.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final int? selectedIndex;

  const PaymentMethodsScreen({super.key, this.selectedIndex});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  late Logger logger;
  late PaymentMethodApiService paymentMethodApiService;
  late UserPaymentMethodApiService userPaymentMethodApiService;
  List<PaymentMethod>? paymentMethods;
  bool _isLoading = true;
  bool _isButtonLoading = true;
  String? _error;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _initializedComponents();
    _fetchPaymentMethods();
  }

  void _initializedComponents() {
    logger = Logger('PaymentMethodScreen');
    paymentMethodApiService = PaymentMethodApiService();
    userPaymentMethodApiService = UserPaymentMethodApiService();
    _selectedIndex = widget.selectedIndex;
  }

  Future<void> _fetchPaymentMethods() async {
    try {
      final response = await paymentMethodApiService.fetchPaymentMethods();

      setState(() {
        _isLoading = false;
        _isButtonLoading = false;
        _error = null;
        paymentMethods = response.isNotEmpty ? response : null;
      });

      if (response.isEmpty) {
        setState(() {
          paymentMethods = [];
          _error = 'No payment methods available.';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isButtonLoading = false;
        _error = e.toString();
      });

      logger.severe('An error occured $_error');
    }
  }

  void _onPaymentMethodSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _saveUserPaymentMethod() async {
    setState(() {
      _isButtonLoading = true;
    });
    try {
      if (_selectedIndex == null) return;

      final response = await userPaymentMethodApiService.saveUserPaymentMethod(
        _selectedIndex!,
      );

      if (!mounted) return;

      setState(() {
        _isButtonLoading = false;
      });

      if (response?['data'] != null) {
        SnackBarUtils.showSnackBar(context, response!['message']);
      } else {
        SnackBarUtils.showSnackBar(context, 'Failed to save payment method!');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isButtonLoading = false;
      });
      logger.severe('Error saving user payment method $e');
    }
  }

  void _onConfirm() {
    if (_selectedIndex == null) {
      SnackBarUtils.showWarning(
        navigatorKey.currentContext!,
        'Please select a payment method',
      );

      return;
    }

    final selectedMethod = paymentMethods![_selectedIndex!];

    switch (selectedMethod.code.toLowerCase()) {
      case 'card':
        Navigator.pushNamed(
          navigatorKey.currentContext!,
          '/card-add-payment-method',
        );
        break;
      case 'gcash':
        _openGcash();
        break;
      case 'cash':
        _saveUserPaymentMethod();
        break;
      default:
        SnackBarUtils.showWarning(
          navigatorKey.currentContext!,
          'Payment method not supported.',
        );
    }
  }

  void _openGcash() {}

  Widget _buildPaymentMethodItems() {
    return SelectableIconList(
      selectedIndex: _selectedIndex,
      options: paymentMethods != null
          ? paymentMethods!
                .map(
                  (pm) => {
                    'name': pm.name,
                    'code': pm.code,
                    'icon': pm.code,
                    'onTap': () {
                      _onPaymentMethodSelected(paymentMethods!.indexOf(pm));
                    },
                  },
                )
                .toList()
          : [],
    );
  }

  Widget _buildState() {
    if (_error != null) {
      return ErrorStateWidget(
        errorText: 'Error fetchig Payment methods. Please Try again.',
        onPressed: _fetchPaymentMethods,
      );
    }

    return _isLoading
        ? Center(
            child: CircularProgressIndicator(color: AppColorScheme.royalBlue),
          )
        : _buildPaymentMethodItems();
  }

  Widget _buildConfirmButton() {
    return SafeArea(
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
                onPressed: !_isButtonLoading ? _onConfirm : null,
                child: _isButtonLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColorScheme.royalBlue,
                        ),
                      )
                    : const Text(
                        "Confirm",
                        style: TextStyle(fontSize: 16, color: Colors.white),
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
      backgroundColor: AppColorScheme.backgroundGrey,
      appBar: myAppBar(title: 'Select a payment method'),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(navigatorKey.currentContext!).size.height -
                kToolbarHeight -
                MediaQuery.of(navigatorKey.currentContext!).padding.top -
                100,
          ),
          child: _buildState(),
        ),
      ),

      bottomNavigationBar: _buildConfirmButton(),
    );
  }
}
