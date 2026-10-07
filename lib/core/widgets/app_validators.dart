// ============================================================
// AppValidators — সব form এর জন্য একই validation নিয়ম
// ------------------------------------------------------------
// আগে প্রতিটা screen নিজের মতো করে লিখত — কোথাও "Please enter
// name", কোথাও "Required", কোথাও একেবারেই নেই। ফলে একই ভুল (যেমন
// টাকার ঘরে অক্ষর, ১০ সংখ্যার ফোন নম্বর) কিছু screen এ ধরা পড়ত,
// কিছুতে সোজা server এ চলে যেত।
//
// ব্যবহার:
//   validator: AppValidators.required('Product name'),
//   validator: AppValidators.amount('Selling price'),
//   validator: AppValidators.combine([
//     AppValidators.required('Phone'),
//     AppValidators.phone(),
//   ]),
// ============================================================

typedef AppValidator = String? Function(String? value);

class AppValidators {
  AppValidators._();

  static String _t(String? v) => (v ?? '').trim();

  /// খালি রাখা যাবে না
  static AppValidator required(String field) =>
      (v) => _t(v).isEmpty ? '$field is required' : null;

  /// একাধিক নিয়ম পরপর — প্রথম ভুলটাই দেখায়
  static AppValidator combine(List<AppValidator> rules) => (v) {
        for (final r in rules) {
          final e = r(v);
          if (e != null) return e;
        }
        return null;
      };

  /// সংখ্যা (খালি রাখা যাবে যদি required = false)
  static AppValidator number(
    String field, {
    bool required = false,
    bool allowZero = true,
    bool allowNegative = false,
    double? max,
  }) =>
      (v) {
        final text = _t(v);
        if (text.isEmpty) return required ? '$field is required' : null;
        final n = double.tryParse(text);
        if (n == null) return 'Enter a valid number';
        if (!allowNegative && n < 0) return '$field cannot be negative';
        if (!allowZero && n == 0) return '$field must be greater than 0';
        if (max != null && n > max) {
          return '$field cannot exceed ${max.toStringAsFixed(max % 1 == 0 ? 0 : 2)}';
        }
        return null;
      };

  /// টাকার অঙ্ক — required, ০ এর বেশি, সর্বোচ্চ ২ দশমিক
  static AppValidator amount(String field, {double? max, bool required = true}) =>
      (v) {
        final text = _t(v);
        if (text.isEmpty) return required ? '$field is required' : null;
        final n = double.tryParse(text);
        if (n == null) return 'Enter a valid amount';
        if (n <= 0) return '$field must be greater than 0';
        if (text.contains('.') && text.split('.').last.length > 2) {
          return 'Use at most 2 decimal places';
        }
        if (max != null && n > max) {
          return '$field cannot exceed ${max.toStringAsFixed(2)}';
        }
        return null;
      };

  /// পূর্ণ সংখ্যা (quantity, stock)
  static AppValidator integer(String field,
          {bool required = false, int min = 0}) =>
      (v) {
        final text = _t(v);
        if (text.isEmpty) return required ? '$field is required' : null;
        final n = int.tryParse(text);
        if (n == null) return 'Enter a whole number';
        if (n < min) return '$field must be at least $min';
        return null;
      };

  /// শতাংশ ০–১০০
  static AppValidator percent(String field) =>
      number(field, max: 100);

  /// বাংলাদেশি মোবাইল নম্বর: 01XXXXXXXXX (১১ সংখ্যা), +880 / 880 সহও চলে
  static AppValidator phone({bool required = false}) => (v) {
        final raw = _t(v).replaceAll(RegExp(r'[\s-]'), '');
        if (raw.isEmpty) return required ? 'Phone is required' : null;
        final local = raw.startsWith('+880')
            ? '0${raw.substring(4)}'
            : raw.startsWith('880')
                ? '0${raw.substring(3)}'
                : raw;
        if (!RegExp(r'^01[3-9]\d{8}$').hasMatch(local)) {
          return 'Enter a valid mobile number (01XXXXXXXXX)';
        }
        return null;
      };

  static AppValidator email({bool required = false}) => (v) {
        final text = _t(v);
        if (text.isEmpty) return required ? 'Email is required' : null;
        if (!RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$').hasMatch(text)) {
          return 'Enter a valid email address';
        }
        return null;
      };

  /// সর্বনিম্ন / সর্বোচ্চ অক্ষর
  static AppValidator length(String field, {int min = 0, int? max}) => (v) {
        final text = _t(v);
        if (text.isEmpty) return null;
        if (text.length < min) return '$field must be at least $min characters';
        if (max != null && text.length > max) {
          return '$field must be at most $max characters';
        }
        return null;
      };

  /// dropdown এর জন্য — কিছু বাছা হয়নি
  static String? Function(T?) select<T>(String field) =>
      (T? v) => v == null ? 'Please select $field' : null;
}
