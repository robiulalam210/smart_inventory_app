import 'package:intl/intl.dart';

import '../configs/configs.dart';

class AnimatedAmountCounter extends StatelessWidget {
  final double amount;
  final Duration duration;
  final TextStyle? style;
  final String prefix;

  const AnimatedAmountCounter({
    super.key,
    required this.amount,
    this.duration = const Duration(milliseconds: 800),
    this.style,
    this.prefix = '',
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'en_US', symbol: '', decimalDigits: 2);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: amount),
      duration: duration,
      builder: (context, value, child) {
        final formatted = formatCurrency.format(value);
        return Text(
          '$prefix$formatted',
          style: style ?? Theme.of(context).textTheme.titleLarge,
        );
      },
    );
  }
}

class AnimatedCounter extends StatelessWidget {
  final int amount;
  final Duration duration;
  final TextStyle? style;

  const AnimatedCounter({
    super.key,
    required this.amount,
    this.duration = const Duration(milliseconds: 800),
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'en_US', symbol: '', decimalDigits: 0);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: double.parse(amount.toString())),
      duration: duration,
      builder: (context, value, child) {
        final formatted = formatCurrency.format(value);
        return Text(
          formatted,
          style: style ?? Theme.of(context).textTheme.titleLarge,
        );
      },
    );
  }
}
