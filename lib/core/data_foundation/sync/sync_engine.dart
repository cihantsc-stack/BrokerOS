import '../logger/app_logger.dart';
import 'sync_job.dart';

class SyncEngine {
  SyncEngine._();

  static final SyncEngine instance = SyncEngine._();

  final Map<String, SyncJob> _jobs = <String, SyncJob>{};

  bool _isRunning = false;

  bool get isRunning => _isRunning;

  List<SyncJob> get jobs => List<SyncJob>.unmodifiable(_jobs.values);

  void register(SyncJob job) {
    _jobs[job.id] = job;
  }

  Future<void> runAll() async {
    if (_isRunning) {
      return;
    }

    _isRunning = true;

    try {
      for (final SyncJob job in _jobs.values) {
        await run(job.id);
      }
    } finally {
      _isRunning = false;
    }
  }

  Future<void> run(String id) async {
    final SyncJob? job = _jobs[id];

    if (job == null) {
      return;
    }

    job.state = SyncJobState.running;
    job.errorMessage = null;

    try {
      await job.action();
      job.state = SyncJobState.completed;
      job.lastRunAt = DateTime.now();
    } catch (error) {
      job.state = SyncJobState.failed;
      job.errorMessage = error.toString();
      AppLogger.instance.error(
        '${job.title} senkronizasyonu başarısız.',
        error,
      );
    }
  }
}
