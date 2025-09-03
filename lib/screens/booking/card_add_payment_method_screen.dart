import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manong_application/api/payment_method_api_service.dart';
import 'package:manong_application/main.dart';
import 'package:manong_application/theme/colors.dart';
import 'package:manong_application/utils/card_number_input_formatter.dart';
import 'package:manong_application/utils/expiration_date_text_input_formatter.dart';
import 'package:manong_application/utils/snackbar_utils.dart';
import 'package:manong_application/widgets/my_app_bar.dart';

class CardAddPaymentMethodScreen extends StatefulWidget {
  const CardAddPaymentMethodScreen({super.key});
  @override
  State<CardAddPaymentMethodScreen> createState() =>
      _CardAddPaymentMethodScreenState();
}

class _CardAddPaymentMethodScreenState
    extends State<CardAddPaymentMethodScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();
  final TextEditingController _cardHolderNameController =
      TextEditingController();

  bool _isLoading = false;

  InputDecoration _inputDecoration(
    String hint, {
    Widget? suffixIcon,
    String? labelText,
    TextStyle? labelStyle,
    FloatingLabelBehavior? floatingLabelBehavior,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColorScheme.royalBlue, width: 2),
      ),
      suffixIcon: suffixIcon,
      labelText: labelText,
      labelStyle: labelStyle,
      floatingLabelBehavior: floatingLabelBehavior,
    );
  }

  Widget _buildCardForm() {
    return Padding(
      padding: EdgeInsets.all(18),
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: _inputDecoration(
              '',
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.black),
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _cardNumberController,
            decoration: _inputDecoration('Card Number'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CardNumberInputFormatter(),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // TextField inputFormatters for MM/YY
              Expanded(
                child: TextFormField(
                  controller: _expController,
                  decoration: _inputDecoration('MM/YY'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    ExpirationDateTextInputFormatter(),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: TextFormField(
                  controller: _cvcController,
                  decoration: _inputDecoration(
                    'CVC',
                    suffixIcon: Icon(Icons.credit_card),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          TextFormField(
            controller: _cardHolderNameController,
            decoration: _inputDecoration(
              '',
              labelText: 'Name of the card holder',
              labelStyle: TextStyle(color: Colors.black),
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorScheme.royalBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _submitCard,
              child: _isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitCard() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final expParts = _expController.text.split('/');
      final expMonth = expParts[0];
      final expYear = expParts[1];

      final response = await PaymentMethodApiService().createCard(
        number: _cardNumberController.text.replaceAll(' ', ''),
        expMonth: expMonth,
        expYear: expYear,
        cvc: _cvcController.text,
        cardHolderName: _cardHolderNameController.text,
        email: _emailController.text,
      );

      if (response != null) {
        SnackBarUtils.showInfo(
          navigatorKey.currentContext!,
          'Card added successfully!',
        );
      }
    } catch (e) {
      SnackBarUtils.showError(
        navigatorKey.currentContext!,
        'Failed to save card: $e',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorScheme.backgroundGrey,
      appBar: myAppBar(title: 'Add a credit or debit card'),
      body: Form(child: _buildCardForm()),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _cardNumberController.dispose();
    _expController.dispose();
    _cvcController.dispose();
    _cardHolderNameController.dispose();
    super.dispose();
  }
}
