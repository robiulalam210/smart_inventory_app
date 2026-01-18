import 'package:flutter/material.dart';
import '../../../../core/utilities/amount_counter.dart';
import '../../../../core/configs/configs.dart';

Widget dashboardCardItem({
  required String title,
  required dynamic value,
  required IconData icon,
  required Color color,
  bool isCurrency = false,
  int itemsPerRow = 5, // Set 5 or 4 depending on layout
}) {
  return LayoutBuilder(builder: (context, constraints) {
    final screenWidth = constraints.maxWidth;
    final isWideScreen = screenWidth > 600;
    final boxWidth = isWideScreen ? (screenWidth / itemsPerRow - 10) : (screenWidth / 2 - 10);

    return Container(
      height: 120,
      width: boxWidth,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(12),
      //   border: Border(
      //     right: BorderSide(color: color, width: 10.0),
      //     bottom: BorderSide(color: color, width: 1.5),
      //     top: BorderSide(color: color, width: 1.5),
      //     left: BorderSide(color: color, width: 1.5),
      //   ),
      // ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(icon, color: color, size: 35),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                if (isCurrency)
                  AnimatedAmountCounter(
                    amount: (value is double)
                        ? value
                        : double.tryParse(value.toString()) ?? 0.0,
                    prefix: '৳ ',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  AnimatedCounter(
                    amount: (value is int)
                        ? value
                        : int.tryParse(value.toString()) ?? 0,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  });
}
