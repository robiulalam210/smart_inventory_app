import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import '../../../../../core/configs/app_urls.dart';
import 'connectivity_event.dart';
import 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  Timer? _debounceTimer;
  bool? _lastState; // Cache last connectivity state to prevent repeated events

  ConnectivityBloc() : super(ConnectivityConnecting()) {
    on<ConnectivityChanged>((event, emit) {
      if (event.isConnected) {
        emit(ConnectivityOnline());
      } else {
        emit(ConnectivityOffline());
      }
    });

    _initializeConnectivity();
    _monitorConnectivity();
  }

  /// FIX: আগে google.com দেখা হত — local/LAN server এ internet না থাকলে app ভুল করে
  /// "Offline" দেখাত। এখন নিজের server এর /health/ দেখা হয়।
  Future<bool> _hasInternet() async {
    try {
      final res = await http
          .get(Uri.parse('${AppUrls.baseUrlMain}/health/'))
          .timeout(const Duration(seconds: 5));
      return res.statusCode >= 200 && res.statusCode < 500;
    } catch (e) {
      return false;
    }
  }

  /// Initial connectivity check
  /// FIX: connectivity_plus 6.x এ checkConnectivity() একটা List দেয় — আগের `result == wifi`
  /// তুলনা সবসময় false হত, তাই app শুরুতেই "Offline" ধরে নিত।
  void _initializeConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    final hasInterface = results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet);

    final isConnected = hasInterface && await _hasInternet();
    _emitIfChanged(isConnected);
  }

  /// Listen for connectivity changes and debounce
  void _monitorConnectivity() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((results) {
          // Cancel previous timer if a new event comes quickly
          _debounceTimer?.cancel();
          _debounceTimer = Timer(const Duration(milliseconds: 500), () async {

            final hasInterface = results.any((result) =>
            result == ConnectivityResult.mobile ||
                result == ConnectivityResult.wifi ||
                result == ConnectivityResult.ethernet);

            final isConnected = hasInterface && await _hasInternet();
            _emitIfChanged(isConnected);
          });
        });
  }

  /// Emit event only if state changed
  void _emitIfChanged(bool isConnected) {
    if (_lastState != isConnected) {
      _lastState = isConnected;
      add(ConnectivityChanged(isConnected));
    } else {
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
