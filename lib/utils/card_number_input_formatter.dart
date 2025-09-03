import 'package:flutter/services.dart';

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    var spaced = '';
    for (var i = 0; i < digitsOnly.length; i++) {
      if (i != 0 && i % 4 == 0) spaced += ' ';
      spaced += digitsOnly[i];
    }
    return TextEditingValue(
      text: spaced,
      selection: TextSelection.collapsed(offset: spaced.length),
    );
  }
}
