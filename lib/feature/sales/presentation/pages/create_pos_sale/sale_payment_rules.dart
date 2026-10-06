/// বিক্রির সময় টাকা গ্রহণের নিয়ম — সব POS screen (desktop, mobile, short sale) একই নিয়ম মানে।
///
/// আগের সমস্যা:
/// - "With Money Receipt" টিক না থাকলেও paid_amount যেত, কিন্তু payment method / account যেত না
///   → server error ("Payment method is required") অথবা টাকা কোনো account এ ঢুকত না।
/// - Account বাছাই না করেও submit হয়ে যেত।
///
/// এখন:
/// - টিক না থাকলে paid_amount = 0 (পুরো বিল বাকি)।
/// - টিক থাকলে paid_amount = customer যত দিয়েছে; payment method ও account বাধ্যতামূলক।
/// - বেশি দিলে server নিজেই paid = বিল, বাকিটা change হিসাব করে।
class SalePaymentRules {
  SalePaymentRules._();

  static double parseAmount(String? text) =>
      double.tryParse((text ?? '').replaceAll(',', '').trim()) ?? 0.0;

  /// body তে payment অংশ বসায়। সমস্যা থাকলে বাংলা error message ফেরত দেয়, নাহলে null।
  static String? apply({
    required Map<String, dynamic> body,
    required bool receivePayment,
    required String receivedText,
    required String? paymentMethod,
    required dynamic accountId,
    required double grandTotal,
    required bool isWalkIn,
  }) {
    final received = receivePayment ? parseAmount(receivedText) : 0.0;

    if (received < 0) return 'Paid amount ঋণাত্মক হতে পারে না।';

    if (isWalkIn && received + 0.009 < grandTotal) {
      return 'Walk-in customer এর কাছে বাকি রাখা যায় না — পুরো ${grandTotal.toStringAsFixed(2)} টাকা নিতে হবে। '
          '"With Money Receipt" টিক দিয়ে টাকার পরিমাণ লিখুন।';
    }

    body.remove('payment_method');
    body.remove('account_id');
    body.remove('due_amount'); // server নিজে হিসাব করে, app এর হিসাব পাঠানোর দরকার নেই

    if (received > 0) {
      if (paymentMethod == null || paymentMethod.trim().isEmpty) {
        return 'Payment method বাছাই করুন।';
      }
      final acc = accountId?.toString() ?? '';
      if (acc.isEmpty || acc == 'null') {
        return 'যে account এ টাকা জমা হবে সেটি বাছাই করুন।';
      }
      body['payment_method'] = paymentMethod;
      body['account_id'] = acc;
    }

    body['paid_amount'] = double.parse(received.toStringAsFixed(2));
    body['with_money_receipt'] = received > 0 ? 'Yes' : 'No';
    return null;
  }

  /// "ফেরত দিতে হবে" (change) — শুধু বেশি দিলে, কখনো ঋণাত্মক নয়
  static double change(double received, double grandTotal) =>
      received > grandTotal ? received - grandTotal : 0.0;

  /// এখনো বাকি (due)
  static double due(double received, double grandTotal) =>
      grandTotal > received ? grandTotal - received : 0.0;
}
