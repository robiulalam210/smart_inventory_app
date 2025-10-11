import 'package:flutter/material.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';

import '../../../../core/configs/app_colors.dart';
import '../../../../core/configs/app_sizes.dart';
import '../../../../responsive.dart';



class AssignedLeads extends StatelessWidget {
  const AssignedLeads({super.key,});

  @override
  Widget build(BuildContext context) {
    List<Segment> segments = [
      Segment(
        value:  0,
        color: const Color(0xffFA8D03),
        label: const Text(
          'Total Customers: ',
          style: TextStyle(color: Color(0xffFA8D03), fontWeight: FontWeight.bold),
        ),
      ),
      Segment(
        value: 0,
        color: Colors.amber,
        label: const Text(
          'Total Suppliers: ',
          style: TextStyle(color: Color(0xffFA8D03), fontWeight: FontWeight.bold),
        ),
      ),
    ];
    final progressBar = PrimerProgressBar(
      segments: segments,
      barStyle: const SegmentedBarStyle(backgroundColor: Color.fromARGB(255, 237, 251, 255)),
    );

    // Statistics row ("statis")
    Widget statisticsRow = Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            label: "Customers",
            value: "0",
            color: const Color(0xffFA8D03),
          ),
          _StatItem(
            label: "Suppliers",
            value:  "0",
            color: Colors.amber,
          ),
          _StatItem(
            label: "Total",
            value: "0",
            color: Colors.blue,
          ),
        ],
      ),
    );

    return Center(
      child: Container(
        height: Responsive.isMobile(context)
            ? AppSizes.height(context) * 0.18
            : AppSizes.height(context) * 0.13,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(10, 7, 51, 96),
              blurRadius: 10,
              spreadRadius: 10,
              offset: Offset(0, 10),
            )
          ],
        ),
        width: AppSizes.width(context) * 0.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            progressBar,
            statisticsRow,
          ],
        ),
      ),
    );
  }
}

// A simple stat item widget for clean code
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ],
  );
}