import 'dart:async';

class DelayThrottle {
  final int _duration;
  Execution? _currentCallback;
  Timer? _currentTimer;
  Completer<void>? _completer;
  int _lastTimerTime = 0;

  DelayThrottle(int milliseconds)
      : _duration = milliseconds;

  void operator <<(Execution callback){
    _currentCallback = callback;
    if (_currentTimer != null){
      _currentTimer!.cancel();
      _currentTimer = null;
    }

    if (_completer == null || _completer!.isCompleted){
      _completer = Completer<void>();
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now -_lastTimerTime;
    if (diff >= _duration){
      /// init new timer
      _currentTimer = Timer(Duration(milliseconds: _duration), () {
        if (identical(_currentCallback, callback)){
          _currentCallback!();
          _completer!.complete(null);
        }
      });
      _lastTimerTime = now;
    }
    else {
      /// replace current execution
      _currentTimer = Timer(Duration(milliseconds: _duration - diff), () {
        if (identical(_currentCallback, callback)){
          _currentCallback!();
          _completer!.complete(null);
        }
      });
    }

  }

  Future<void> isComplete(){
    return _completer!.future;
  }
}

typedef Execution = void Function();
