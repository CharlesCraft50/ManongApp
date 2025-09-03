import 'package:manong_application/models/payment_method.dart';

class UserPaymentMethod {
  final int id;
  final int userId;
  final int paymentMethodId;
  final String? paymongoId;
  final String? last4;
  final int? expMonth;
  final int? expYear;
  final int? billingEmail;
  final int isDefault;
  final PaymentMethod paymentMethod;

  UserPaymentMethod({
    required this.id,
    required this.userId,
    required this.paymentMethod,
    this.paymongoId,
    this.last4,
    this.expMonth,
    this.expYear,
    this.billingEmail,
    required this.isDefault,
    required this.paymentMethodId,
  });

  factory UserPaymentMethod.fromJson(Map<String, dynamic> json) {
    return UserPaymentMethod(
      id: json['id'],
      userId: json['userId'],
      paymentMethodId: json['paymentMethodId'],
      paymongoId: json['paymongoId'],
      last4: json['last4'],
      expMonth: json['expMonth'],
      expYear: json['expYear'],
      isDefault: json['isDefault'],
      paymentMethod: PaymentMethod.fromJson(json['paymentMethod']),
    );
  }
}
