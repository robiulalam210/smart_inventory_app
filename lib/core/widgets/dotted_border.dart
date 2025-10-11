import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class DottedLine extends StatelessWidget {
  final double height;
  final Color color;
  final List<double> dashPattern;
  final double strokeWidth;

  const DottedLine({
    super.key,
    this.height = 1,
    this.color = Colors.black,
    this.dashPattern = const [4, 4],
    this.strokeWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      options: CustomPathDottedBorderOptions(
        dashPattern: dashPattern,
        strokeWidth: strokeWidth,
        color: color,
        padding: EdgeInsets.zero,
        customPath: (size) {
          final path = Path();
          path.moveTo(0, size.height);
          path.lineTo(size.width, size.height);
          return path;
        },
      ),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: const DecoratedBox(
          decoration: BoxDecoration(color: Colors.transparent),
        ),
      ),
    );
  }
}
