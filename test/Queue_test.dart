import 'package:ds_future/ds_future.dart';
import 'package:test/test.dart';

main() {
  test('Pending job', () async {
    await queue(1, [].map((e) => () async {}));

    final ans = await queue(
        1,
        [1].map((e) => () async {
              return e;
            })).timeout(Duration(seconds: 2));
    expect(ans, [1]);

  });

  test('Exception job', () async {
    expect(queue(1, [1].map((e) => () async {
      throw 'Exception message';
    })), throwsA(equals({'Code': 'QueueException', 'Error': 'Exception message'})));
  });

  group('results order', () {
    test('simple order', () async {
      final done = [];
      final ans2 = await queue(
          2,
          [2, 1].map((e) => () async {
            await Future.delayed(Duration(milliseconds: 100 * e));
            done.add(e);
            return e;
          }));
      expect(done, [1, 2], reason: "Results should be done independently");
      expect(ans2, [2, 1], reason: "Results should keep same orders");
    });

    test('more than limit', () async {

      final done = [];
      final ans2 = await queue(
          2,
          [4, 3, 2, 1].map((e) => () async {
            await Future.delayed(Duration(milliseconds: 100 * e));
            done.add(e);
            return e;
          }));
      expect(done, [3, 4, 1, 2], reason: "Results should be done independently");
      expect(ans2, [4, 3, 2, 1], reason: "Results should keep same orders");
    });
  });
}
