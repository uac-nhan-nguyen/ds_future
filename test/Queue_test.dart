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
    expect(
        queue(
            1,
            [1].map((e) => () async {
                  throw 'Exception message';
                })),
        throwsA(equals({'Code': 'QueueException', 'Error': 'Exception message'})));

    expect(
        queue(
            2,
            [1, 2].map((e) => () async {
                  throw 'Exception message ${e}';
                })),
        throwsA(equals({'Code': 'QueueException', 'Error': 'Exception message 1'})));
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
          [5, 4, 3, 1].map((e) => () async {
                await Future.delayed(Duration(milliseconds: 200 * e));
                done.add(e);
                return e;
              }));
      expect(done, [4, 5, 1, 3], reason: "Results should be done independently");
      expect(ans2, [5, 4, 3, 1], reason: "Results should keep same orders");
    });
  });

  test("List extension should work", () async {
    final done = [];
    final ans2 = await [5, 4, 3, 1].queue(2, (e) async {
      await Future.delayed(Duration(milliseconds: 200 * e));
      done.add(e);
      return e;
    });
    expect(done, [4, 5, 1, 3], reason: "Results should be done independently");
    expect(ans2, [5, 4, 3, 1], reason: "Results should keep same orders");
  });
}
