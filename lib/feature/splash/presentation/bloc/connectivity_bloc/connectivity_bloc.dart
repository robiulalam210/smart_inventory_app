import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'connectivity_event.dart';
import 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

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

  /// Check if internet is really reachable
  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('example.com')
          .timeout(const Duration(seconds: 2));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _initializeConnectivity() async {
    // Start with "connecting"
    add(ConnectivityChanged(false));

    final result = await _connectivity.checkConnectivity();
    final hasInterface = result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet;

    final isConnected = hasInterface && await _hasInternet();
    add(ConnectivityChanged(isConnected));
  }

  void _monitorConnectivity() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((results) async {
          final hasInterface = results.any((r) =>
          r == ConnectivityResult.mobile ||
              r == ConnectivityResult.wifi ||
              r == ConnectivityResult.ethernet);

          final isConnected = hasInterface && await _hasInternet();
          add(ConnectivityChanged(isConnected));
        });
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
