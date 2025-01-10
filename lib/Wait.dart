part of 'ds_future.dart';

Future<T> waitUntil<T>({
  required int intervalMilliseconds,
  required Future<T> Function(Completer<T> completer) process,
}) async {
  Completer<T> completer = Completer();

  bool isInProcess = false;

  await process(completer);

  if (!completer.isCompleted){
    Timer.periodic(Duration(milliseconds: intervalMilliseconds), (timer) async {
      if (completer.isCompleted) {
        timer.cancel();
        return;
      }

      if (isInProcess) return;
      isInProcess = true;

      await process(completer);


      isInProcess = false;
    });

  }
  return completer.future;
}

Future<T> waitUntilFound<T>({
  required int intervalMilliseconds,
  required Future<T?> Function() process,
}) {
  final Completer<T> completer = Completer();
  bool inProcess = false;
  Timer.periodic(Duration(milliseconds: intervalMilliseconds), (timer) async {

    if (inProcess) {
      return;
    }
    inProcess = true;

    final result = await process();
    if (result != null) {
      timer.cancel();
      completer.complete(result);
    }
    inProcess = false;
  });

  return completer.future;
}

Future<T> waitUntilFoundInStream<T>({
  required Stream<T> stream,
  required bool Function(T data) predicate,
}) {
  final Completer<T> completer = Completer();
  late final StreamSubscription<T> sub;
  sub = stream.listen((data) {
    if (predicate(data)) {
      completer.complete(data);
      sub.cancel();
    }
  });
  return completer.future;
}
