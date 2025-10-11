import 'dart:async';

import '../configs/configs.dart';

class AutoTimerService {
  static final AutoTimerService _instance = AutoTimerService._internal();
  factory AutoTimerService() => _instance;

  AutoTimerService._internal();

  Timer? _timer;

  void startTimer() {
    // Cancel if already running
    _timer?.cancel();

    _timer = Timer.periodic(Duration(minutes: 60), (timer) {
      debugPrint("⏰ Called every 60 minutes");
      yourFunction();
    });


    debugPrint("✅ Repeating timer started (every 1 hour)");
  }


  void cancelTimer() {
    _timer?.cancel();
    debugPrint("🛑 Timer cancelled");
  }

  void yourFunction() {
    // Your actual logic here
    debugPrint("🚀 Function executed!");
  }
}
