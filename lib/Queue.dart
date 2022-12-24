import 'dart:async';

class Queue<T> {
  final int limit;
  int _currentRunningJobs = 0;
  final List<_Job<T>> _queueJobs = [];
  final Completer<List<T>> _completer = Completer();
  final List<T> _results = [];

  Queue({
    this.limit = 40,
    Iterable<JobFunction<T>> jobs = const [],
  }) {
    addAll(jobs.toList());
  }

  void addAll(List<JobFunction<T>> jobs) {
    _queueJobs.addAll(jobs.map((e) => _Job(job: e)));
    if (jobs.isNotEmpty) {
      startNextJob();
    }
  }

  void startNextJob() {
    if (_currentRunningJobs < limit && _queueJobs.isNotEmpty) {
      _currentRunningJobs++;
      _queueJobs.removeAt(0).job().then((value) {
        if (!_completer.isCompleted) throw 'unexpected: Should not have any pending job if already complete';
        _results.add(value);
        _currentRunningJobs--;
        startNextJob();
      });

      if (_currentRunningJobs < limit) {
        startNextJob();
      }
    } else if (_currentRunningJobs == 0 && _queueJobs.isEmpty && !_completer.isCompleted) {
      _completer.complete(_results);
    }
  }

  Future<List<T>> get results => _completer.future;
}

class _Job<T> {
  final JobFunction<T> job;

  _Job({required this.job});
}

typedef JobFunction<T> = Future<T> Function();

Future<List<T>> queue<T>(int limit, Iterable<JobFunction<T>> jobs) => Queue(
      limit: limit,
      jobs: jobs,
    ).results;
