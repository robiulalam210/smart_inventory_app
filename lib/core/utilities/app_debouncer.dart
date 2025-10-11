import 'dart:async';
import 'package:flutter/material.dart';

class AppDebouncer {
  final int millisecond;
  Timer? _timer;

  AppDebouncer({required this.millisecond});

  void run(VoidCallback action) {
    if (_timer?.isActive ?? false) _timer?.cancel();
    _timer = Timer(Duration(milliseconds: millisecond), action);
  }

  void cancel() {
    _timer?.cancel();
  }
}


