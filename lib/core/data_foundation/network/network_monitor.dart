import 'dart:async';

import 'connection_status.dart';

class NetworkMonitor {
  NetworkMonitor._();

  static final NetworkMonitor instance = NetworkMonitor._();

  final StreamController<ConnectionStatus> _controller =
      StreamController<ConnectionStatus>.broadcast();

  ConnectionStatus _status = ConnectionStatus.online;

  ConnectionStatus get currentStatus => _status;

  Stream<ConnectionStatus> get statusStream => _controller.stream;

  void setStatus(ConnectionStatus status) {
    if (_status == status) {
      return;
    }

    _status = status;
    _controller.add(status);
  }

  Future<ConnectionStatus> check() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _status;
  }
}
