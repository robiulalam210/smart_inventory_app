import 'package:flutter/material.dart';

/// টেবিলের vertical + horizontal [ScrollController] rebuild এর মধ্যেও ধরে রাখে এবং dispose করে।
///
/// আগে প্রতিটা desktop টেবিল `build()` এর ভেতরে `ScrollController()` বানাত — ফলে প্রতি rebuild এ
/// scroll position উপরে চলে যেত আর controller leak হতো।
class TableScrollControllers extends StatefulWidget {
  final Widget Function(
    BuildContext context,
    ScrollController vertical,
    ScrollController horizontal,
  ) builder;

  const TableScrollControllers({super.key, required this.builder});

  @override
  State<TableScrollControllers> createState() => _TableScrollControllersState();
}

class _TableScrollControllersState extends State<TableScrollControllers> {
  final ScrollController _vertical = ScrollController();
  final ScrollController _horizontal = ScrollController();

  @override
  void dispose() {
    _vertical.dispose();
    _horizontal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _vertical, _horizontal);
}
