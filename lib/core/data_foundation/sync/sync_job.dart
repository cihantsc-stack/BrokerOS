enum SyncJobState { waiting, running, completed, failed }

class SyncJob {
  final String id;
  final String title;
  final Future<void> Function() action;

  SyncJobState state;
  DateTime? lastRunAt;
  String? errorMessage;

  SyncJob({
    required this.id,
    required this.title,
    required this.action,
    this.state = SyncJobState.waiting,
    this.lastRunAt,
    this.errorMessage,
  });
}
