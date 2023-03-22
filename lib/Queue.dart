import 'dart:async';

class Queue<T> {
  final int limit;
  int _currentRunningJobs = 0;
  int _count = 0;
  final List<JobFunction<T>> _queueJobs;
  final Completer<List<T>> _completer = Completer();
  final Map<int, T> _results = {};

  Queue({
    required this.limit,
    required List<JobFunction<T>> jobs,
  }) : _queueJobs = jobs;

  void startNextJob() {
    if (_currentRunningJobs < limit && _queueJobs.isNotEmpty) {
      final index = _count++;
      _currentRunningJobs++;
      final job = _queueJobs.removeAt(0);

      job().then((value) {
        if (_completer.isCompleted) throw 'unexpected: Should not have any pending job if already complete';
        _results[index] = value;
        _currentRunningJobs--;
        startNextJob();
      }).catchError((e) {
        if (!_completer.isCompleted){
          _completer.completeError({
            'Code': 'QueueException',
            'Error': e,
          });
        }
      });
      if (!_completer.isCompleted && _currentRunningJobs < limit) {
        startNextJob();
      }
    } else if (_currentRunningJobs == 0 && _queueJobs.isEmpty && !_completer.isCompleted) {
      /// trigger complete
      final entries = _results.entries.toList();
      entries.sort((a, b) => a.key - b.key);
      _completer.complete(entries.map((e) => e.value).toList(growable: false));
    }
  }

  Future<List<T>> get results => _completer.future;
}

typedef JobFunction<T> = Future<T> Function();

Future<List<T>> queue<T>(int limit, Iterable<JobFunction<T>> jobs) async {
  if (jobs.isEmpty) return [];
  final q = Queue<T>(
    limit: limit,
    jobs: jobs.toList(),
  );
  q.startNextJob();
  return await q.results;
}
