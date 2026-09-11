enum NetworkStatus { idle, loading, success, offline, failure }

class NetworkState {
  final NetworkStatus status;
  final String? message;
  const NetworkState._(this.status, [this.message]);
  const NetworkState.idle() : this._(NetworkStatus.idle);
  const NetworkState.loading() : this._(NetworkStatus.loading);
  const NetworkState.success() : this._(NetworkStatus.success);
  const NetworkState.offline([
    String message = 'İnternet bağlantısı bulunamadı.',
  ]) : this._(NetworkStatus.offline, message);
  const NetworkState.failure(String message)
    : this._(NetworkStatus.failure, message);
}
