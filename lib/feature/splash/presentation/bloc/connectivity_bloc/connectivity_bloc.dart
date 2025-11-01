import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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

  /// Check if internet is actually reachable
  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      final hasInternet = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      return hasInternet;
    } catch (e) {
      return false;
    }
  }

  /// Initial connectivity check
  void _initializeConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    final hasInterface = result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet;

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
