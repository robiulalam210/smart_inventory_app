import 'dart:ui' show FontFeature;

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
  // KPI card — মান বড় ও গাঢ় (সবচেয়ে দরকারি তথ্য), শিরোনাম ছোট ও ধূসর।
  // আগে FittedBox পুরো card ছোট-বড় করত, তাই একেক card এ একেক মাপের
  // লেখা দেখাত। এখন সব card এ লেখার মাপ এক, শুধু লম্বা মান "…" হয়।
  return LayoutBuilder(builder: (context, constraints) {
    final screenWidth = constraints.maxWidth;
    final isWideScreen = screenWidth > 600;
    final boxWidth = isWideScreen
        ? (screenWidth / itemsPerRow - 10)
        : (screenWidth / 2 - 10);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final valueStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.text(context),
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Container(
      height: 104,
      width: boxWidth,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text(context).withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: isCurrency
                      ? AnimatedAmountCounter(
                          amount: (value is double)
                              ? value
                              : double.tryParse(value.toString()) ?? 0.0,
                          prefix: '৳ ',
                          style: valueStyle,
                        )
                      : AnimatedCounter(
                          amount: (value is int)
                              ? value
                              : int.tryParse(value.toString()) ?? 0,
                          style: valueStyle,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  });
}
